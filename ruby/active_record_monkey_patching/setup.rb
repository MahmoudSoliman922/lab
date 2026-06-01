# Boots ActiveRecord against a file-based SQLite database so you can inspect it
# with `sqlite3 demo.db` from another terminal while the demo is running.
# force: :cascade drops and recreates the table on each run for a clean slate.

require 'active_record'

DB_PATH = File.expand_path('demo.db', __dir__)

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: DB_PATH)
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :users, force: :cascade do |t|
    t.string  :name
    t.string  :email
    t.integer :age
    t.timestamps
  end
end

class User < ActiveRecord::Base
end

# Seed data so there's something to query/print.
User.create!(name: 'Alice', email: 'alice@example.com', age: 30)
User.create!(name: 'Bob',   email: 'bob@example.com',   age: 25)
