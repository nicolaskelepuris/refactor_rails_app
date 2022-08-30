# frozen_string_literal: true

module Todos
  class List < Micro::Case
    attribute :user_id
    attribute :status, default: ->(value) { value&.strip&.downcase }

    def call!
      todos =
        case status
        when 'overdue' then ::Todo.overdue
        when 'completed' then ::Todo.completed
        when 'uncompleted' then ::Todo.uncompleted
        else ::Todo.all
        end

      Success result: { todos: todos.where(user_id: user_id).map(&:serialize_as_json) }
    end
  end
end