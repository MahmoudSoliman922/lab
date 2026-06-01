# bundle exec ruby main.rb

require_relative 'setup'
require_relative 'patch'

SEP      = ('─' * 62).freeze
MUTATION = 'mutation { updateUserAge(id: "1", age: 99) { user { name age } } }'

def banner(title)
  puts "\n#{SEP}"
  puts "  #{title}"
  puts SEP
end

# ── Phase 1: Capture ──────────────────────────────────────────────────────────
banner 'Phase 1 — Capture Mode  (execute intercepted, mutation not run)'
CaptureContext.start!

AppSchema.execute(MUTATION)

puts "  Intercepted #{CaptureContext.mutations.size} mutation(s) — schema never executed:"
CaptureContext.mutations.each_with_index do |m, i|
  puts "  [#{i}] #{m[:query].strip}"
end
puts "  DB → Alice: age=#{User.find_by(name: 'Alice').age}  (unchanged)"

# ── Phase 2: Passthrough ──────────────────────────────────────────────────────
banner 'Phase 2 — Passthrough  (patch off, mutation executes normally)'
CaptureContext.stop!

result = AppSchema.execute(MUTATION)
data   = result['data']&.dig('updateUserAge', 'user')
puts "  Result → #{data.inspect}"
puts "  DB → Alice: age=#{User.find_by(name: 'Alice').age}"

puts "\nDone."
