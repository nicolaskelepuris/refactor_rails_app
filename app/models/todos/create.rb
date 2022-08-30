# frozen_string_literal: true

module Todos
  class Create < Micro::Case
    attributes :user_id, :title, :due_at

    def call!
      todo = ::Todo.create(user_id: user_id, title: title, due_at: due_at)

      return Failure :unprocessable_entity, result: { todo: todo.errors.messages } unless todo.valid?

      return Success :todo_created, result: { todo: todo }
    end
  end
end
