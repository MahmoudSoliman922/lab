# bundle exec ruby main.rb

require_relative 'setup'
require_relative 'patch'

SEP = ('─' * 62).freeze

EVENTS = [
  { topic: 'user_events', payload: { event: 'user_created', name: 'Alice' }.to_json },
  { topic: 'user_events', payload: { event: 'user_updated', name: 'Bob'   }.to_json }
]

def banner(title)
  puts "\n#{SEP}"
  puts "  #{title}"
  puts SEP
end

# ── Phase 1: Capture ──────────────────────────────────────────────────────────
banner 'Phase 1 — Capture Mode  (produce_sync intercepted, nothing sent)'
CaptureContext.start!

EVENTS.each { |e| PRODUCER.produce_sync(**e) }

puts "  Intercepted #{CaptureContext.messages.size} message(s) — Kafka never touched:"
CaptureContext.messages.each_with_index do |msg, i|
  puts "  [#{i}] topic=#{msg[:topic]}  payload=#{msg[:payload]}"
end

# ── Phase 2: Passthrough ──────────────────────────────────────────────────────
banner 'Phase 2 — Passthrough  (patch off, produce_sync called normally)'
CaptureContext.stop!

EVENTS.each { |e| PRODUCER.produce_sync(**e) }
puts "  #{EVENTS.size} message(s) dispatched (deliver: false in demo — real broker in prod)"

puts "\nDone."
