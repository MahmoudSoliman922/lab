module RollbackContext
  @mode      = :real
  @snapshots = []

  def self.dry_run!
    @mode      = :dry
    @snapshots = []
  end

  def self.real_run!
    @mode = :real
  end

  def self.dry_run?
    @mode == :dry
  end

  def self.add_snapshot(table:, record_id:, operation:, before:)
    @snapshots << { table: table, record_id: record_id, operation: operation, before: before }
  end

  def self.snapshots
    @snapshots.dup
  end

  # Restores every captured :update back to its before-state using update_columns,
  # which bypasses all callbacks (including our own patch) and validations.
  def self.rollback!
    @snapshots.each do |snap|
      next unless snap[:operation] == :update

      klass = ActiveRecord::Base.descendants.find { |k| k.table_name == snap[:table] }
      next unless klass

      # update_columns bypasses callbacks (including our own patch) and validations.
      klass.find(snap[:record_id]).update_columns(snap[:before].except('id'))
    end

    @snapshots = []
    @mode      = :real
  end
end
