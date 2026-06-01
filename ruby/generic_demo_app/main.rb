# All three patches active in the same process.
#
#   bundle exec ruby main.rb

require_relative 'setup'
require_relative 'setup_graphql'
require_relative 'setup_karafka'

require_relative 'patches/ar_patch'
require_relative 'patches/graphql_patch'
require_relative 'patches/kafka_patch'

SEP = ('─' * 62).freeze

EVENTS = [
  { topic: 'user_events', payload: { event: 'user_created', name: 'Alice' }.to_json },
  { topic: 'user_events', payload: { event: 'user_updated', name: 'Bob'   }.to_json }
]

BOB_MUTATION = 'mutation { updateUserAge(id: "2", age: 88) { user { name age } } }'

def banner(title)
  puts "\n#{SEP}"
  puts "  #{title}"
  puts SEP
end

def show_db
  puts "  DB → Alice: age=#{User.find_by(name: 'Alice').age}  " \
       "Bob: age=#{User.find_by(name: 'Bob').age}"
end

def run_mutation
  result = AppSchema.execute(BOB_MUTATION)
  data   = result['data']&.dig('updateUserAge', 'user')
  if CaptureContext.capturing?
    puts "  GraphQL → #{CaptureContext.mutations.size} mutation(s) captured, schema never executed"
  else
    puts "  GraphQL → #{data.inspect}"
  end
end

def run_kafka
  EVENTS.each { |e| PRODUCER.produce_sync(**e) }
  if CaptureContext.capturing?
    puts "  Kafka   → #{CaptureContext.messages.size} message(s) captured, Kafka never touched"
  else
    puts "  Kafka   → #{EVENTS.size} message(s) dispatched"
  end
end

# ── Phase 1: Capture / Dry Run ────────────────────────────────────────────────
banner 'Phase 1 — Capture / Dry Run  (all three patches intercept)'

RollbackContext.dry_run!
CaptureContext.start!

result = User.find_by(name: 'Alice').update(age: 99)
puts "  AR      → alice.update(age: 99) returned #{result.inspect}  (aborted)"

run_mutation
run_kafka
show_db

puts "\n  AR snapshot:    #{RollbackContext.snapshots.first&.slice(:table, :record_id, :operation)}"
puts "  GraphQL captured: #{CaptureContext.mutations.size} mutation(s)"
puts "  Kafka captured:   #{CaptureContext.messages.map { |m| m[:topic] }}"

# ── Phase 2: Real Run ─────────────────────────────────────────────────────────
banner 'Phase 2 — Real Run  (all three side effects applied)'

RollbackContext.real_run!
CaptureContext.stop!

User.find_by(name: 'Alice').update!(age: 99)
puts "  AR      → alice.update!(age: 99) saved"

run_mutation
run_kafka
show_db

# ── Phase 3: Rollback ─────────────────────────────────────────────────────────
banner 'Phase 3 — Rollback  (AR only — GraphQL and Kafka are capture-only)'

RollbackContext.rollback!

show_db
puts "  GraphQL → capture-only, no rollback"
puts "  Kafka   → capture-only, no rollback"

puts "\nDone."
