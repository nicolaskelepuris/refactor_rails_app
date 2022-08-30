require 'rails_helper'

RSpec.describe Todos::Find, type: :use_case do
  describe 'failures' do
    context 'no todo matching id and user_id is found' do
      it 'return :not_found' do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        user.todos.create(title: "any title")
        other_user = User.create(name: "other_name", email: "other_email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        other_user.todos.create(title: "other title")

        # When
        result = Todos::Find.call(user_id: 1, id: 2)

        # Then
        expect(result).to be_a_failure
        expect(result.type).to be(:not_found)
        expect(result.data.keys).to contain_exactly(:todo)
        expect(result[:todo]).to eq({ :id => "not found" })
      end
      
      it 'return :not_found' do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        user.todos.create(title: "any title")
        other_user = User.create(name: "other_name", email: "other_email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        other_user.todos.create(title: "other title")

        # When
        result = Todos::Find.call(user_id: 2, id: 1)

        # Then
        expect(result).to be_a_failure
        expect(result.type).to be(:not_found)
        expect(result.data.keys).to contain_exactly(:todo)
        expect(result[:todo]).to eq({ :id => "not found" })
      end
    end
  end

  describe 'success' do
    context 'todo matching id and user_id is found' do
      it 'return :not_found' do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        todo = user.todos.create(title: "any title")
        other_user = User.create(name: "other_name", email: "other_email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        other_user.todos.create(title: "other title")

        # When
        result = Todos::Find.call(user_id: 1, id: 1)

        # Then
        expect(result).to be_a_success
        expect(result.type).to be(:todo_found)
        expect(result.data.keys).to contain_exactly(:todo)
        expect(result[:todo]).to eq(todo)
      end
    end
  end
end