require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  describe "post /users/registrations" do
    context "with no params" do
      it "should respond with 400" do
        post :create

        assert_response 400

        expect(JSON.parse(response.body)).to eq({ "error" => "param is missing or the value is empty: user" })
      end
    end

    context "missing any param" do
      context "missing password confirmation" do
        it "should respond with 422" do
          post :create, params: { user: { name: 'any name', email: 'any.email@email.com', password: 'any password' } }
  
          assert_response 422
  
          expect(JSON.parse(response.body)).to eq({ "user" => { "password_confirmation" => ["can't be blank"] } })
        end
      end

      context "missing password" do
        it "should respond with 422" do
          post :create, params: { user: { name: 'any name', email: 'any.email@email.com', password_confirmation: 'any password' } }
  
          assert_response 422
  
          expect(JSON.parse(response.body)).to eq({ "user" => { "password" => ["can't be blank"] } })
        end
      end

      context "missing name" do
        it "should respond with 422" do
          post :create, params: { user: { email: 'any.email@email.com', password: 'any password', password_confirmation: 'any password' } }
  
          assert_response 422
  
          expect(JSON.parse(response.body)).to eq({ "user" => { "name" => ["can't be blank"] } })
        end
      end

      context "missing email" do
        it "should respond with 422" do
          post :create, params: { user: { name: 'any name', password: 'any password', password_confirmation: 'any password' } }
  
          assert_response 422
  
          expect(JSON.parse(response.body)).to eq({ "user" => { "email" => ["can't be blank", "is invalid"] } })
        end
      end
    end

    context "with required param blank" do
      context "password confirmation is blank" do
        it "should respond with 422" do
          post :create, params: { user: { name: 'any name', email: 'any.email@email.com', password: 'any password', password_confirmation: ' ' } }
  
          assert_response 422
  
          expect(JSON.parse(response.body)).to eq({ "user" => { "password_confirmation" => ["can't be blank"] } })
        end
      end

      context "password is blank" do
        it "should respond with 422" do
          post :create, params: { user: { name: 'any name', email: 'any.email@email.com', password: ' ', password_confirmation: 'any password' } }
  
          assert_response 422
  
          expect(JSON.parse(response.body)).to eq({ "user" => { "password" => ["can't be blank"] } })
        end
      end

      context "name is blank" do
        it "should respond with 422" do
          post :create, params: { user: { name: ' ', email: 'any.email@email.com', password: 'any password', password_confirmation: 'any password' } }
  
          assert_response 422
  
          expect(JSON.parse(response.body)).to eq({ "user" => { "name" => ["can't be blank"] } })
        end
      end

      context "email is blank" do
        it "should respond with 422" do
          post :create, params: { user: { name: 'any name', email: ' ', password: 'any password', password_confirmation: 'any password' } }
  
          assert_response 422
  
          expect(JSON.parse(response.body)).to eq({ "user" => { "email" => ["can't be blank", "is invalid"] } })
        end
      end
    end

    context "password and password_confirmation are different" do
      it "should respond with 422" do
        post :create, params: { user: { name: 'any name', email: 'any.email@email.com', password: 'any password', password_confirmation: 'a different password' } }
  
        assert_response 422

        expect(JSON.parse(response.body)).to eq({ "user" => { "password_confirmation" => ["doesn't match password"] } })
      end
    end

    context "email is already been used" do
      it "should respond with 422" do
        # Given
        email = 'any.email@email.com'
        User.create(name: 'name', email: email, token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        
        # When
        post :create, params: { user: { name: 'any name', email: email, password: 'any password', password_confirmation: 'any password' } }
        
        # Then
        assert_response 422

        expect(JSON.parse(response.body)).to eq({ "user" => { "email" => ["has already been taken"] } })
      end
    end

    context "valid params" do
      it "should respond with 201, create the user and enqueue the welcome email" do
        # Given
        ActiveJob::Base.queue_adapter = :test
        user_params = { user: { name: 'any name', email: 'any.email@email.com', password: 'any password', password_confirmation: 'any password' } }
        
        # When
        post :create, params: user_params

        # Then
        assert_response 201

        # Fact: user response must have user's token, id and name
        body = JSON.parse(response.body)

        user_id = body.dig("user", "id")
        expect(user_id).to be_a(Integer)

        expect(body.dig("user", "name")).to eq("any name")

        UUID = /\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b/
        user_token = body.dig("user", "token")
        expect(user_token).to match(UUID)

        expect(body["user"].size).to  be(3)

        # Fact: user will be persisted
        user = User.find_by(id: user_id)
        expect(user.name).to eq('any name')
        expect(user.email).to eq('any.email@email.com')
        expect(user.token).to eq(user_token)

        # Fact: after user creation the welcome email is enqueued to be sent
        job = ActiveJob::Base.queue_adapter.enqueued_jobs.first

        expect(job["job_class"]).to eq("ActionMailer::MailDeliveryJob")

        expect(job["arguments"][0..1].join('#')).to eq("Users::Mailer#welcome")        

        job_user_gid = GlobalID.parse(job["arguments"].last.dig("params", "user", "_aj_globalid"))
        expect(user_id.to_s).to eq(job_user_gid.model_id)
      end
    end
  end
end
