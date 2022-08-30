# frozen_string_literal: true

module Todos
  class Uncomplete < Micro::Case
    attributes :todo

    def call!
      todo.uncomplete!

      Success :todo_uncompleted, result: { todo: todo }
    end
  end
end
