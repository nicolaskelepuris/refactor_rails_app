# frozen_string_literal: true

module Todos
  class Update < Micro::Case
    attributes :todo, :title, :due_at

    def call!
      todo.update(title: title, due_at: due_at)

      return Failure :unprocessable_entity, result: { todo: todo.errors.messages } unless todo.valid?

      Success :todo_updated, result: { todo: todo }
    end
  end
end
