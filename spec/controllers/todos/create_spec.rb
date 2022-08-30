require 'rails_helper'

RSpec.describe TodosController, type: :controller do
  describe "create a todo" do
    context "without passing token" do
      it "respond with 401" do
        post :create, params: { todo: { title: "any title" } }

        assert_response 401
      end
    end

    context "with no params" do
      it "respond with 400" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        request.headers["Authorization"] = "Bearer token=\"#{user.token}\""

        # When
        post :create

        # Then
        assert_response 400

        expect(JSON.parse(response.body)).to eq({ "error" => "param is missing or the value is empty: todo" })
      end
    end

    context "with missing title" do
      it "respond with 400" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        request.headers["Authorization"] = "Bearer token=\"#{user.token}\""

        # When
        post :create, params: { todo: {} }

        # Then
        assert_response 400

        expect(JSON.parse(response.body)).to eq({ "error" => "param is missing or the value is empty: todo" })
      end
    end

    context "with blank title" do
      it "respond with 422" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        request.headers["Authorization"] = "Bearer token=\"#{user.token}\""
        title = [nil, "", " "].sample

        # When
        post :create, params: { todo: { title: title } }

        # Then
        assert_response 422

        expect(JSON.parse(response.body)).to eq({ "todo" => { "title" => ["can't be blank"] } })
      end
    end

    context "with valid params" do
      it "respond with 201" do
        # Given
        user = User.create(name: "name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        request.headers["Authorization"] = "Bearer token=\"#{user.token}\""
        due_at = [nil, Time.current.next_month.iso8601(3)].sample

        # When
        post :create, params: { todo: { title: "any title", due_at: due_at } }

        # Then
        assert_response 201

        body = JSON.parse(response.body)
        expect(body.dig("todo", "id")).to be_a(Integer)
        expect(body.dig("todo", "title")).to eq("any title")
        expect(body.dig("todo", "status")).to eq("uncompleted")
        ISO8601_DATETIME = /\A\d{4}(-\d\d(-\d\d(T\d\d:\d\d(:\d\d)?(\.\d+)?(([+-]\d\d:\d\d)|Z)?)?)?)?\z/i
        expect(body.dig("todo", "due_at")).to match(ISO8601_DATETIME) unless due_at == nil
        expect(body.dig("todo", "created_at")).to match(ISO8601_DATETIME)
        expect(body.dig("todo", "updated_at")).to match(ISO8601_DATETIME)

        todo = user.todos.find_by(id: body.dig("todo", "id"))
        expect(todo.title).to eq("any title")
        expect(todo.due_at).to eq(due_at)
        expect(todo.status).to eq("uncompleted")
      end
    end
  end
end
