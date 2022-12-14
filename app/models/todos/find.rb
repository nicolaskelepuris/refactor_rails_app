# frozen_string_literal: true

module Todos
  class Find < Micro::Case
    attributes :user_id, :id

    def call!
      todo = ::Todo.find_by(id: id, user_id: user_id)

      return Failure :not_found, result: { todo: { id: 'not found' } } if todo.nil?

      Success :todo_found, result: { todo: todo }
    end
  end
end
