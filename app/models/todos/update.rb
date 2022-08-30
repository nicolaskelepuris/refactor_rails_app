# frozen_string_literal: true

class Todos::Update < Micro::Case
  attributes :user_id, :id, :title, :due_at

  def call!
    todo = Todo.find_by(id: id, user_id: user_id)

    return Failure :not_found, result: { todo: { id: 'not found' } } if todo.nil?

    todo.update(title: title, due_at: due_at)

    return Failure :unprocessable_entity, result: { todo: todo.errors.messages } unless todo.valid?

    Success result: { todo: todo.serialize_as_json }
  end
end