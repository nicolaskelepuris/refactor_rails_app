# frozen_string_literal: true

module Todos
  class Destroy < Micro::Case
    attributes :todo

    def call!
      todo.destroy

      Success :todo_destroyed, result: { todo: todo }
    end
  end
end
