# frozen_string_literal: true

module Todos
  class Complete < Micro::Case
    attributes :todo

    def call!
      todo.complete!

      Success :todo_completed, result: { todo: todo }
    end
  end
end
