# frozen_string_literal: true

module Users
  class Create < Micro::Case
    attributes :name, :email
    attribute :password, default: ->(value) { value.to_s.strip }
    attribute :password_confirmation, default: ->(value) { value.to_s.strip }

    def call!
      validate_password
        .then(apply(:create_user))
        .then(apply(:send_welcome_email))
        .then(apply(:as_json))
    end

    private
      def validate_password
        errors = {}
        errors[:password] = ["can't be blank"] if password.blank?
        errors[:password_confirmation] = ["can't be blank"] if password_confirmation.blank?

        return Failure :unprocessable_entity, result: { user: errors } if errors.present?
        return Failure :unprocessable_entity, result: { user: { password_confirmation: ["doesn't match password"] } } if password != password_confirmation

        return Success :password_validated
      end

      def create_user
        user = User.create(
          name: name,
          email: email,
          token: ::SecureRandom.uuid,
          password_digest: ::Digest::SHA256.hexdigest(password)
        )

        return Failure :unprocessable_entity, result: { user: user.errors.messages } unless user.valid?

        return Success :user_created, result: { user: user }
      end

      def send_welcome_email(user:, **)
        UserMailer.with(user: user).welcome.deliver_later
        
        return Success :welcome_email_sent
      end

      def as_json(user:, **)
        Success :user_created, result: { user: user.as_json(only: [:id, :name, :token]) }
      end
  end
end