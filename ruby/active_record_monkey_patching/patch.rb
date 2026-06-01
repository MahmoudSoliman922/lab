require_relative 'rollback_context'

# The `if:` guard is re-evaluated on every save, so toggling RollbackContext
# mode mid-session takes effect immediately without reloading the patch.
ActiveRecord::Base.class_eval do
  before_save    :capture_before_save,    if: -> { RollbackContext.dry_run? }
  before_destroy :capture_before_destroy, if: -> { RollbackContext.dry_run? }

  private

  def capture_before_save
    unless new_record?
      # attribute_was() gives the pre-change DB value for dirty columns;
      # read_attribute() gives the current value for clean ones.
      # Together they reconstruct the record's state before this save.
      before = self.class.column_names.to_h do |col|
        [col, attribute_changed?(col) ? attribute_was(col) : read_attribute(col)]
      end

      RollbackContext.add_snapshot(
        table:     self.class.table_name,
        record_id: id,
        operation: :update,
        before:    before
      )
    end

    throw :abort  # always — creates are blocked in dry-run too, just not recorded
  end

  def capture_before_destroy
    RollbackContext.add_snapshot(
      table:     self.class.table_name,
      record_id: id,
      operation: :destroy,
      before:    attributes.dup
    )

    throw :abort
  end
end
