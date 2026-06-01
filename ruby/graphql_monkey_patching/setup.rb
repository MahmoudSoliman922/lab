require 'active_record'
require 'graphql'

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

class User < ActiveRecord::Base; end

User.create!(name: 'Alice', email: 'alice@example.com', age: 30)
User.create!(name: 'Bob',   email: 'bob@example.com',   age: 25)

module Types
  class UserType < GraphQL::Schema::Object
    field :id,    ID,      null: false
    field :name,  String,  null: true
    field :email, String,  null: true
    field :age,   Integer, null: true
  end

  class QueryType < GraphQL::Schema::Object
    field :users, [UserType], null: false
    def users = User.all
  end

  class UpdateUserAgeMutation < GraphQL::Schema::Mutation
    argument :id,  ID,      required: true
    argument :age, Integer, required: true

    field :user, UserType, null: true

    def resolve(id:, age:)
      user = User.find(id)
      user.update!(age: age)
      { user: user.reload }
    end
  end

  class MutationType < GraphQL::Schema::Object
    field :update_user_age, mutation: UpdateUserAgeMutation
  end
end

class AppSchema < GraphQL::Schema
  query    Types::QueryType
  mutation Types::MutationType
end
