require 'rails_helper'

RSpec.describe Todos::Update, type: :use_case do
  describe "failures" do
    context "with missing title" do
      it "return :unprocessable_entity" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        todo = user.todos.create(title: "any title", due_at: Time.current.prev_day)

        # When
        result = Todos::Update.call(todo: todo, due_at: Time.current.prev_day)

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
        todo = user.todos.create(title: "any title", due_at: Time.current.prev_day)
        title = [nil, "", " "].sample

        # When
        result = Todos::Update.call(todo: todo, title: title, due_at: Time.current.prev_day)

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
      it "return updated todo" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        todo = user.todos.create(title: "any title", due_at: Time.current.prev_day)
        new_title = "new title"
        new_due_at = Time.current.next_day.iso8601(3)

        # When
        result = Todos::Update.call(todo: todo, title: new_title, due_at: new_due_at)

        # Then
        expect(result).to be_a_success
        expect(result.type).to be(:todo_updated)
        expect(result.data.keys).to contain_exactly(:todo)
        expect(result[:todo]).to be(todo)
        expect(result[:todo].title).to eq(new_title)
        expect(result[:todo].due_at).to eq(new_due_at)

        todo_from_db = user.todos.find_by(id: todo.id)
        expect(todo_from_db.title).to eq(new_title)
        expect(todo_from_db.due_at).to eq(new_due_at)
      end
    end
  end
end
