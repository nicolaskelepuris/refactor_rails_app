# frozen_string_literal: true

class Users::RegistrationsController < ApplicationController
  def create
    ::Users::Create.call(user_params) do |on|
      on.failure(:unprocessable_entity) { |result| render status: 422, json: { user: result[:user] } }
      on.success(:user_created) { |result| render status: 201, json: { user: result[:user] } }
    end

  rescue ActionController::ParameterMissing => exception
    render_bad_request(exception.message)
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation).to_h
    end

    def render_bad_request(message)
      render status: 400, json: { error: message }
    end
end
