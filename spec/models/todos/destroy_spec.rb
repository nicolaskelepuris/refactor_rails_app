require 'rails_helper'

RSpec.describe Todos::Destroy, type: :use_case do
  describe 'success' do
    it 'return :todo_destroyed' do
      # Given
      user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
      todo = user.todos.create(title: "any title")
      todo_id = todo.id

      # When
      result = Todos::Destroy.call(todo: todo)

      # Then
      expect(result).to be_a_success
      expect(result.type).to be(:todo_destroyed)
      expect(result.data.keys).to contain_exactly(:todo)
      expect(result[:todo]).to eq(todo)

      expect(user.todos.find_by(id: todo_id)).to eq(nil)
    end
  end
end
