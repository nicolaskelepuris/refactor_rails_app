require 'rails_helper'

RSpec.describe Users::Create, type: :use_case do
  describe "failures" do
    context "missing any param" do
      context "missing password confirmation" do
        it "returns a :unprocessable_entity failure" do
          result = Users::Create.call(name: 'any name', email: 'any.email@email.com', password: 'any password')
          
          expect(result).to be_a_failure
          expect(result.type).to be(:unprocessable_entity)
          expect(result.data.keys).to contain_exactly(:user)
          expect(result[:user]).to eq({ :password_confirmation => ["can't be blank"] })
        end
      end

      context "missing password" do
        it "returns a :unprocessable_entity failure" do
          result = Users::Create.call(name: 'any name', email: 'any.email@email.com', password_confirmation: 'any password')
          
          expect(result).to be_a_failure
          expect(result.type).to be(:unprocessable_entity)
          expect(result.data.keys).to contain_exactly(:user)
          expect(result[:user]).to eq({ :password => ["can't be blank"] })
        end
      end

      context "missing name" do
        it "returns a :unprocessable_entity failure" do
          result = Users::Create.call(email: 'any.email@email.com', password: 'any password', password_confirmation: 'any password')
          
          expect(result).to be_a_failure
          expect(result.type).to be(:unprocessable_entity)
          expect(result.data.keys).to contain_exactly(:user)
          expect(result[:user]).to eq({ :name => ["can't be blank"] })
        end
      end

      context "missing email" do
        it "returns a :unprocessable_entity failure" do
          result = Users::Create.call(name: 'any name', password: 'any password', password_confirmation: 'any password')
          
          expect(result).to be_a_failure
          expect(result.type).to be(:unprocessable_entity)
          expect(result.data.keys).to contain_exactly(:user)
          expect(result[:user]).to eq({ :email => ["can't be blank", "is invalid"] })
        end
      end
    end

    context "with required param blank" do
      context "password confirmation is blank" do
        it "returns a :unprocessable_entity failure" do
          result = Users::Create.call(name: 'any name', email: 'any.email@email.com', password: 'any password', password_confirmation: ' ')
          
          expect(result).to be_a_failure
          expect(result.type).to be(:unprocessable_entity)
          expect(result.data.keys).to contain_exactly(:user)
          expect(result[:user]).to eq({ :password_confirmation => ["can't be blank"] })
        end
      end

      context "password is blank" do
        it "returns a :unprocessable_entity failure" do
          result = Users::Create.call(name: 'any name', email: 'any.email@email.com', password: ' ', password_confirmation: 'any password')
          
          expect(result).to be_a_failure
          expect(result.type).to be(:unprocessable_entity)
          expect(result.data.keys).to contain_exactly(:user)
          expect(result[:user]).to eq({ :password => ["can't be blank"] })
        end
      end

      context "name is blank" do
        it "returns a :unprocessable_entity failure" do
          result = Users::Create.call(name: ' ', email: 'any.email@email.com', password: 'any password', password_confirmation: 'any password')
          
          expect(result).to be_a_failure
          expect(result.type).to be(:unprocessable_entity)
          expect(result.data.keys).to contain_exactly(:user)
          expect(result[:user]).to eq({ :name => ["can't be blank"] })
        end
      end

      context "email is blank" do
        it "returns a :unprocessable_entity failure" do
          result = Users::Create.call(name: 'any name', email: ' ', password: 'any password', password_confirmation: 'any password')
          
          expect(result).to be_a_failure
          expect(result.type).to be(:unprocessable_entity)
          expect(result.data.keys).to contain_exactly(:user)
          expect(result[:user]).to eq({ :email => ["can't be blank", "is invalid"] })
        end
      end
    end

    context "password and password_confirmation are different" do
      it "returns a :unprocessable_entity failure" do
        result = Users::Create.call(name: 'any name', email: 'any.email@email.com', password: 'any password', password_confirmation: 'a different password')
          
        expect(result).to be_a_failure
        expect(result.type).to be(:unprocessable_entity)
        expect(result.data.keys).to contain_exactly(:user)
        expect(result[:user]).to eq({ :password_confirmation => ["doesn't match password"] })
      end
    end

    context "email is already been used" do
      it "returns a :unprocessable_entity failure" do
        # Given
        email = 'any.email@email.com'
        User.create(name: 'name', email: email, token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))
        
        # When
        result = Users::Create.call(name: 'any name', email: email, password: 'any password', password_confirmation: 'any password')
        
        # Then
          
        expect(result).to be_a_failure
        expect(result.type).to be(:unprocessable_entity)
        expect(result.data.keys).to contain_exactly(:user)
        expect(result[:user]).to eq({ :email => ["has already been taken"] })
      end
    end
  end

  describe "success" do
    context "valid params" do
      it "should respond with a :user_created success, create the user and enqueue the welcome email" do
        # Given
        ActiveJob::Base.queue_adapter = :test
        user_params = { name: 'any name', email: 'any.email@email.com', password: 'any password', password_confirmation: 'any password' }
        
        # When
        result = Users::Create.call(user_params)

        # Then
        expect(result).to be_a_success
        expect(result.type).to be(:user_created)
        expect(result.data.keys).to contain_exactly(:user)

        # Fact: user response must have user's token, id and name
        user_id = result[:user]["id"]
        expect(user_id).to be_a(Integer)

        expect(result[:user]["name"]).to eq("any name")

        UUID = /\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b/
        user_token = result[:user]["token"]
        expect(user_token).to match(UUID)

        expect(result[:user].size).to  be(3)

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