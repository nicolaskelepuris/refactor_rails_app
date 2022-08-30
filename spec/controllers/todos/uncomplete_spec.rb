require 'rails_helper'

RSpec.describe TodosController, type: :controller do
  describe "uncomplete a todo" do
    context "without passing token" do
      it "respond with 401" do
        get :uncomplete, params: { id: 1 }

        assert_response 401
      end
    end

    context "with an id of a todo that doesn't exist" do
      it "return 404" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        request.headers["Authorization"] = "Bearer token=\"#{user.token}\""

        # When
        get :uncomplete, params: { id: 1 }

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
        todo = user.todos.create(title: "any title", completed_at: Time.current.prev_day)
        todo_id = todo.id

        # When
        get :uncomplete, params: { id: todo_id }

        # Then
        assert_response 200

        body = JSON.parse(response.body)

        expect(body.dig("todo", "id")).to eq(todo_id)
        expect(body.dig("todo", "title")).to eq("any title")
        expect(body.dig("todo", "status")).to eq("uncompleted")
      end
    end
  end
end
