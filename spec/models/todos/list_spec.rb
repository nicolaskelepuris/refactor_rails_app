require 'rails_helper'

RSpec.describe Todos::List, type: :use_case do
  describe 'success' do
    context "no todo found" do
      it 'return empty todos' do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
  
        # When
        result = Todos::List.call(user_id: user.id, status: nil)
  
        # Then
        expect(result).to be_a_success
        expect(result.data.keys).to contain_exactly(:todos)
        expect(result[:todos]).to eq([])
      end
    end

    context "without filtering by status" do
      it "return all todos from user" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        user.todos.create(title: "title 1", due_at: Time.current.prev_day)
        user.todos.create(title: "title 2", due_at: Time.current.next_day)
        user.todos.create(title: "title 3", completed_at: Time.current.prev_day)
        user.todos.create(title: "title 4", completed_at: Time.current.prev_day, due_at: Time.current.prev_day)
        other_user = User.create(name: "other name", email: "other_email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        other_user.todos.create(title: "title 5", due_at: Time.current.prev_day)

        # When
        result = Todos::List.call(user_id: user.id, status: nil)

        # Then
        expect(result).to be_a_success
        expect(result.data.keys).to contain_exactly(:todos)
        expect(result[:todos].size).to eq(4)

        expect(result[:todos][0].title).to eq("title 1")
        expect(result[:todos][0].status).to eq("overdue")

        expect(result[:todos][1].title).to eq("title 2")
        expect(result[:todos][1].status).to eq("uncompleted")

        expect(result[:todos][2].title).to eq("title 3")
        expect(result[:todos][2].status).to eq("completed")

        expect(result[:todos][3].title).to eq("title 4")
        expect(result[:todos][3].status).to eq("completed")
      end
    end

    context "filtering by status" do
      it "return all filtered todos that are from user" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        user.todos.create(title: "title 1", due_at: Time.current.prev_day)
        user.todos.create(title: "title 2", due_at: Time.current.next_day)
        user.todos.create(title: "title 3", completed_at: Time.current.prev_day)
        user.todos.create(title: "title 4", completed_at: Time.current.prev_day, due_at: Time.current.prev_day)
        other_user = User.create(name: "other name", email: "other_email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        other_user.todos.create(title: "title 5", due_at: Time.current.prev_day)
        other_user.todos.create(title: "title 6", due_at: Time.current.next_day)
        other_user.todos.create(title: "title 7", completed_at: Time.current.prev_day)
        other_user.todos.create(title: "title 8", completed_at: Time.current.prev_day, due_at: Time.current.prev_day)
        status = ["overdue", "completed", "uncompleted"].sample

        # When
        result = Todos::List.call(user_id: user.id, status: status)

        # Then
        expect(result).to be_a_success
        expect(result.data.keys).to contain_exactly(:todos)
        expect(result[:todos].size).not_to eq(0)

        statuses = result[:todos].map { |todo| todo.status }
        expect(statuses).to all(eq(status))

        user_todos_ids = user.todos.map { |todo| todo.id }
        response_todos_ids = result[:todos].map { |todo| todo.id }
        expect(user_todos_ids).to include(*response_todos_ids)
      end
    end
  end
end
