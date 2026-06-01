module CaptureContext
  @capturing = false
  @messages  = []

  def self.start!
    @capturing = true
    @messages  = []
  end

  def self.stop!
    @capturing = false
  end

  def self.capturing?
    @capturing
  end

  def self.add(message)
    @messages << { topic: message[:topic], payload: message[:payload] }
  end

  def self.messages
    @messages.dup
  end
end
