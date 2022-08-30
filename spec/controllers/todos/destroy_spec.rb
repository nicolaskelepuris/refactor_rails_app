require 'rails_helper'

RSpec.describe TodosController, type: :controller do
  describe "destroy a todo" do
    context "without passing token" do
      it "respond with 401" do
        get :destroy, params: { id: 1 }

        assert_response 401
      end
    end

    context "with an id of a todo that doesn't exist" do
      it "return 404" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        request.headers["Authorization"] = "Bearer token=\"#{user.token}\""

        # When
        get :destroy, params: { id: 1 }

        # Then
        assert_response 404

        expect(JSON.parse(response.body)).to eq({ "todo" => { "id" => "not found" } })
      end
    end

    context "with id of a existing todo" do
      it "return 200" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        request.headers["Authorization"] = "Bearer token=\"#{user.token}\""
        todo = user.todos.create(title: "any title")
        todo_id = todo.id
        todo_status = todo.status
        todo_due_at = todo.due_at
        todo_created_at = todo.created_at.iso8601(3)
        todo_updated_at = todo.updated_at.iso8601(3)

        # When
        get :destroy, params: { id: todo_id }

        # Then
        assert_response 200

        body = JSON.parse(response.body)

        expect(body.dig("todo", "id")).to eq(todo_id)
        expect(body.dig("todo", "title")).to eq("any title")
        expect(body.dig("todo", "status")).to eq(todo_status)
        expect(body.dig("todo", "due_at")).to eq(todo_due_at)
        expect(body.dig("todo", "created_at")).to eq(todo_created_at)
        expect(body.dig("todo", "updated_at")).to eq(todo_updated_at)

        expect(user.todos.find_by(id: todo_id)).to eq(nil)
      end
    end
  end
end
