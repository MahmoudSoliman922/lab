# Demonstrates the dry-run / real-run / rollback cycle via class_eval on
# ActiveRecord::Base.
#
#   bundle exec ruby main.rb

require_relative 'setup'
require_relative 'patch'

SEP = ('─' * 62).freeze

def banner(title)
  puts "\n#{SEP}"
  puts "  #{title}"
  puts SEP
end

def show_db
  alice = User.find_by(name: 'Alice')
  puts "  DB → Alice: age=#{alice.age}"
end

# ── Phase 1: Dry Run ──────────────────────────────────────────────────────────
# patch is active; save is intercepted and aborted; DB is unchanged
banner 'Phase 1 — Dry Run  (capture snapshot, abort save)'

RollbackContext.dry_run!
alice  = User.find_by(name: 'Alice')
result = alice.update(age: 99)        # update() returns false when save is aborted

puts "  alice.update(age: 99) → #{result.inspect}  (false = aborted by patch)"
show_db
puts "  Snapshot: #{RollbackContext.snapshots.first}"

# ── Phase 2: Real Run ─────────────────────────────────────────────────────────
# patch is still loaded but dry_run? is now false, so callbacks are skipped
banner 'Phase 2 — Real Run  (side effect applied)'

RollbackContext.real_run!
User.find_by(name: 'Alice').update!(age: 99)

show_db

# ── Phase 3: Rollback ─────────────────────────────────────────────────────────
# uses the Phase 1 snapshot to restore the record via update_columns
# (bypasses callbacks, so our patch does not interfere)
banner 'Phase 3 — Rollback  (restore from dry-run snapshot)'

RollbackContext.rollback!

show_db
puts "\nDone."
