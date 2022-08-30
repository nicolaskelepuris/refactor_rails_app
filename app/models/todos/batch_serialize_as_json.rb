# frozen_string_literal: true

module Todos
  class BatchSerializeAsJson < Micro::Case
    attributes :todos

    def call!
      Success result: { todos: todos.map { |todo| SerializeAsJson.call(todo: todo)[:todo] } }
    end
  end
end
