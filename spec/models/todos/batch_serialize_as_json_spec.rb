require 'rails_helper'

RSpec.describe Todos::BatchSerializeAsJson, type: :use_case do
  describe 'success' do
    it 'return todos serialized' do
      # Given
      user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
      todo = user.todos.create(title: "any title")      
      todo_2 = user.todos.create(title: "any title")

      # When
      result = Todos::BatchSerializeAsJson.call(todos: [todo, todo_2])

      # Then
      expect(result).to be_a_success
      expect(result.data.keys).to contain_exactly(:todos)
      expect(result[:todos]).to eq([
        {
          "completed_at" => todo.completed_at&.iso8601(3),
          "created_at" => todo.created_at.iso8601(3),
          "due_at" => todo.due_at,
          "id" => todo.id,
          "status" => todo.status,
          "title" => todo.title,
          "updated_at" => todo.updated_at.iso8601(3),
        },
        {
          "completed_at" => todo_2.completed_at&.iso8601(3),
          "created_at" => todo_2.created_at.iso8601(3),
          "due_at" => todo_2.due_at,
          "id" => todo_2.id,
          "status" => todo_2.status,
          "title" => todo_2.title,
          "updated_at" => todo_2.updated_at.iso8601(3),
        }
      ])
    end
  end
end
