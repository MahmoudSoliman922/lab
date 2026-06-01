require 'waterdrop'

PRODUCER = WaterDrop::Producer.new do |config|
  config.deliver = false
  config.kafka   = { 'bootstrap.servers': 'localhost:9092' }
  config.logger  = Logger.new(File::NULL)
end

at_exit { PRODUCER.close }
