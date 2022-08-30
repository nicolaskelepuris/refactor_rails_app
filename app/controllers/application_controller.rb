# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  protected

    def authenticate_user
      head :unauthorized unless current_user
    end

    def current_user
      @current_user ||= authenticate_with_http_token do |token|
        User.find_by(token: token)
      end
    end

    def render_json(status, json = {})
      render status: status, json: json
    end

    def show_parameter_missing_error(exception)
      render_json(400, error: exception.message)
    end
end
