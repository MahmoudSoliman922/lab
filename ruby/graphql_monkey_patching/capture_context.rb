module CaptureContext
  @capturing = false
  @mutations = []

  def self.start!     = (@capturing = true; @mutations = [])
  def self.stop!      = (@capturing = false)
  def self.capturing? = @capturing

  def self.add(query:, variables: nil)
    @mutations << { query: query, variables: variables }
  end

  def self.mutations = @mutations.dup
end
