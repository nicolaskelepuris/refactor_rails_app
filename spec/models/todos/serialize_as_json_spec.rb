require 'rails_helper'

RSpec.describe Todos::SerializeAsJson, type: :use_case do
  describe 'success' do
    it 'return todo serialized' do
      # Given
      user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
      todo = user.todos.create(title: "any title")

      # When
      result = Todos::SerializeAsJson.call(todo: todo)

      # Then
      expect(result).to be_a_success
      expect(result.data.keys).to contain_exactly(:todo)
      expect(result[:todo]).to eq({
        "completed_at" => todo.completed_at&.iso8601(3),
        "created_at" => todo.created_at.iso8601(3),
        "due_at" => todo.due_at,
        "id" => todo.id,
        "status" => todo.status,
        "title" => todo.title,
        "updated_at" => todo.updated_at.iso8601(3),
      })
    end
  end
end
