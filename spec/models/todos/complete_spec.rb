require 'rails_helper'

RSpec.describe Todos::Complete, type: :use_case do
  describe 'success' do
    it 'return :todo_completed' do
      # Given
      user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
      todo = user.todos.create(title: "any title")

      # When
      result = Todos::Complete.call(todo: todo)

      # Then
      expect(result).to be_a_success
      expect(result.type).to be(:todo_completed)
      expect(result.data.keys).to contain_exactly(:todo)
      expect(result[:todo]).to eq(todo)
      expect(todo.status).to eq("completed")

      todo_from_db = user.todos.find_by(id: todo.id)
      expect(todo_from_db.status).to eq("completed")
    end
  end
end
