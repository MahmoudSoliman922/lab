require_relative 'capture_context'

WaterDrop::Producer.class_eval do
  alias_method :original_produce_sync, :produce_sync

  def produce_sync(**kwargs)
    if CaptureContext.capturing?
      CaptureContext.add(kwargs)
      return
    end

    original_produce_sync(**kwargs)
  end
end
