require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe "welcome" do
    it "is created with correct values" do
      # Given
      user = User.create(name: "any name", email: "email@email.com", token: SecureRandom.uuid, password_digest: Digest::SHA256.hexdigest('password'))

      # When
      email = UserMailer.with(user: user).welcome
      email.deliver_now

      # Then
      expect(email.from).to eq(["from@example.com"])
      expect(email.to).to eq(["email@email.com"])
      expect(email.subject).to eq("Welcome aboard")
      expect(email.body.to_s).to eq("Hi any name, thanks for signing up...")
    end
  end
end
