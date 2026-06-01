module CaptureContext
  @capturing = false
  @messages  = []  # Kafka messages (via Kafka patch)
  @mutations = []  # GraphQL mutations (via GraphQL patch)

  def self.start!
    @capturing = true
    @messages  = []
    @mutations = []
  end

  def self.stop!      = (@capturing = false)
  def self.capturing? = @capturing

  def self.add(message)
    @messages << { topic: message[:topic], payload: message[:payload] }
  end

  def self.add_mutation(query:, variables: nil)
    @mutations << { query: query, variables: variables }
  end

  def self.messages  = @messages.dup
  def self.mutations = @mutations.dup
end
