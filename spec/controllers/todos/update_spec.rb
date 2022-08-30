require 'rails_helper'

RSpec.describe TodosController, type: :controller do
  describe "update a todo" do
    context "without passing token" do
      it "respond with 401" do
        post :update, params: { id: 1, todo: { title: "any title" } }

        assert_response 401
      end
    end

    context "with blank title" do
      it "respond with 422" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        request.headers["Authorization"] = "Bearer token=\"#{user.token}\""
        todo = user.todos.create(title: "any title")
        title = [nil, "", " "].sample

        # When
        post :update, params: { id: todo.id, todo: { title: title } }

        # Then
        assert_response 422

        expect(JSON.parse(response.body)).to eq({ "todo" => { "title" => ["can't be blank"] } })
      end
    end

    context "with valid params" do
      it "respond with 200" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        request.headers["Authorization"] = "Bearer token=\"#{user.token}\""
        todo = user.todos.create(title: "any title")
        todo_id = todo.id
        todo_status = todo.status
        todo_due_at = todo.due_at
        todo_created_at = todo.created_at.iso8601(3)
        todo_updated_at = todo.updated_at.iso8601(3)

        new_title = "new title"
        new_due_at = [nil, Time.current.next_month.iso8601(3)].sample

        # When
        post :update, params: { id: todo.id, todo: { title: new_title, due_at: new_due_at } }

        # Then
        assert_response 200

        
        body = JSON.parse(response.body)

        expect(body.dig("todo", "id")).to eq(todo_id)
        expect(body.dig("todo", "title")).to eq(new_title)
        expect(body.dig("todo", "status")).to eq(todo_status)
        expect(body.dig("todo", "due_at")).to eq(new_due_at)
        expect(body.dig("todo", "created_at")).to eq(todo_created_at)
        expect(body.dig("todo", "updated_at")).not_to eq(todo_updated_at)

        todo = user.todos.find_by(id: todo_id)
        expect(todo.title).to eq(new_title)
        expect(todo.due_at).to eq(new_due_at)
        expect(body.dig("todo", "status")).to eq(todo_status)
        expect(body.dig("todo", "created_at")).to eq(todo_created_at)
        expect(body.dig("todo", "updated_at")).not_to eq(todo_updated_at)
      end
    end
  end
end
