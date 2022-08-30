require 'rails_helper'

RSpec.describe TodosController, type: :controller do
  describe "index" do
    context "without passing token" do
      it "respond with 401" do
        get :index

        assert_response 401
      end
    end

    context "no todos found" do
      it "return 200" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        request.headers["Authorization"] = "Bearer token=\"#{user.token}\""

        # When
        get :index

        # Then
        assert_response 200

        expect(JSON.parse(response.body)).to eq({ "todos" => [] })
      end
    end

    context "without filtering by status" do
      it "return 200 and show all todos from current user" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        request.headers["Authorization"] = "Bearer token=\"#{user.token}\""
        user.todos.create(title: "title 1", due_at: Time.current.prev_day)
        user.todos.create(title: "title 2", due_at: Time.current.next_day)
        user.todos.create(title: "title 3", completed_at: Time.current.prev_day)
        user.todos.create(title: "title 4", completed_at: Time.current.prev_day, due_at: Time.current.prev_day)
        other_user = User.create(name: "other name", email: "other_email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        other_user.todos.create(title: "title 5", due_at: Time.current.prev_day)

        # When
        get :index

        # Then
        assert_response 200

        body = JSON.parse(response.body)

        expect(body.dig("todos").size).to eq(4)

        expect(body.dig("todos")[0]["title"]).to eq("title 1")
        expect(body.dig("todos")[0]["status"]).to eq("overdue")

        expect(body.dig("todos")[1]["title"]).to eq("title 2")
        expect(body.dig("todos")[1]["status"]).to eq("uncompleted")

        expect(body.dig("todos")[2]["title"]).to eq("title 3")
        expect(body.dig("todos")[2]["status"]).to eq("completed")

        expect(body.dig("todos")[3]["title"]).to eq("title 4")
        expect(body.dig("todos")[3]["status"]).to eq("completed")
      end
    end

    context "filtering by status" do
      it "return 200 and show all filtered todos" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        request.headers["Authorization"] = "Bearer token=\"#{user.token}\""
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
        get :index, params: { status: status }

        # Then
        assert_response 200

        body = JSON.parse(response.body)

        expect(body.dig("todos").size).not_to eq(0)

        statuses = body.dig("todos").map { |todo| todo["status"] }
        expect(statuses).to all(eq(status))
        
        user_todos_ids = user.todos.map { |todo| todo.id }
        response_todos_ids = body.dig("todos").map { |todo| todo["id"] }
        expect(user_todos_ids).to include(*response_todos_ids)
      end
    end
  end
end
