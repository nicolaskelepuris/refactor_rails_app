# frozen_string_literal: true

class Todos::Complete < Micro::Case
  attributes :user_id, :id

  def call!
    todo = Todo.find_by(id: id, user_id: user_id)

    return Failure :not_found, result: { todo: { id: 'not found' } } if todo.nil?

    todo.complete!

    Success result: { todo: todo.serialize_as_json }
  end
end
