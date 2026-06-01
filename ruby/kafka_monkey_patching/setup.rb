require 'waterdrop'

# deliver: false — WaterDrop goes through its full pipeline (middleware,
# instrumentation) but skips the actual rdkafka delivery, so no broker is
# needed for the demo.
PRODUCER = WaterDrop::Producer.new do |config|
  config.deliver = false
  config.kafka   = { 'bootstrap.servers': 'localhost:9092' }
  config.logger  = Logger.new(File::NULL)
end

at_exit { PRODUCER.close }
