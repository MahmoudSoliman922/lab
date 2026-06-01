# Boots a minimal GraphQL schema backed by the in-memory User model from setup.rb.
# Requiring this file gives you an AppSchema ready to execute queries.

require 'graphql'
require_relative 'setup'

module Types
  class UserType < GraphQL::Schema::Object
    field :id,    ID,      null: false
    field :name,  String,  null: true
    field :email, String,  null: true
    field :age,   Integer, null: true
  end

  class QueryType < GraphQL::Schema::Object
    field :users, [UserType], null: false
    field :user, UserType, null: true do
      argument :id, ID, required: true
    end

    def users          = User.all
    def user(id:)      = User.find_by(id: id)
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
