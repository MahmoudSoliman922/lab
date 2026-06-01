require_relative '../capture_context'

AppSchema.singleton_class.class_eval do
  alias_method :original_execute, :execute

  def execute(query_str = nil, **kwargs)
    if CaptureContext.capturing?
      CaptureContext.add_mutation(query: query_str, variables: kwargs[:variables])
      return {}
    end

    original_execute(query_str, **kwargs)
  end
end
