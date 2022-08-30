require 'rails_helper'

RSpec.describe Todos::Create, type: :use_case do
  describe "failures" do
    context "with missing title" do
      it "return :unprocessable_entity" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))

        # When
        result = Todos::Create.call(user_id: user.id, due_at: Time.current.prev_day)

        # Then
        expect(result).to be_a_failure
        expect(result.type).to be(:unprocessable_entity)
        expect(result.data.keys).to contain_exactly(:todo)
        expect(result[:todo]).to eq({ title: ["can't be blank"] })
      end
    end

    context "with blank title" do
      it "return :unprocessable_entity" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        title = [nil, "", " "].sample

        # When
        result = Todos::Create.call(user_id: user.id, title: title, due_at: Time.current.prev_day)

        # Then
        expect(result).to be_a_failure
        expect(result.type).to be(:unprocessable_entity)
        expect(result.data.keys).to contain_exactly(:todo)
        expect(result[:todo]).to eq({ title: ["can't be blank"] })
      end
    end
  end

  describe 'success' do
    context "with valid params" do
      it "return created todo" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))

        # When
        result = Todos::Create.call(user_id: user.id, title: "any title", due_at: Time.current.prev_day)

        # Then
        expect(result).to be_a_success
        expect(result.type).to be(:todo_created)
        expect(result.data.keys).to contain_exactly(:todo)
        expect(result[:todo]).to be_a(Todo)

        expect(user.todos.find_by(id: result[:todo].id)).not_to be(nil)
      end
    end
  end
end
