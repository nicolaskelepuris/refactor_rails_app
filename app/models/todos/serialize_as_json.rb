# frozen_string_literal: true

module Todos
  class SerializeAsJson < Micro::Case
    attributes :todo

    def call!
      Success result: { todo: todo.as_json(except: [:user_id], methods: :status) }
    end
  end
end
