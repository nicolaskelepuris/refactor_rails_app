require 'rails_helper'

RSpec.describe Todos::Uncomplete, type: :use_case do
  describe 'success' do
    it 'return :todo_uncompleted' do
      # Given
      user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
      todo = user.todos.create(title: "any title")

      # When
      result = Todos::Uncomplete.call(todo: todo)

      # Then
      expect(result).to be_a_success
      expect(result.type).to be(:todo_uncompleted)
      expect(result.data.keys).to contain_exactly(:todo)
      expect(result[:todo]).to eq(todo)
      expect(todo.status).to eq("uncompleted")

      todo_from_db = user.todos.find_by(id: todo.id)
      expect(todo_from_db.status).to eq("uncompleted")
    end
  end
end
