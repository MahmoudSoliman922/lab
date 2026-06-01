require_relative 'capture_context'

# Patches AppSchema.execute — the schema's single entry point for ALL GraphQL
# operations. In capture mode the mutation is recorded and original_execute is
# never called, so nothing is executed — same pattern as WaterDrop::Producer.
AppSchema.singleton_class.class_eval do
  alias_method :original_execute, :execute

  def execute(query_str = nil, **kwargs)
    if CaptureContext.capturing?
      CaptureContext.add(query: query_str, variables: kwargs[:variables])
      return {}
    end

    original_execute(query_str, **kwargs)
  end
end
