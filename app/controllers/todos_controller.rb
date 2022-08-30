# frozen_string_literal: true

class TodosController < ApplicationController
  before_action :authenticate_user

  def index
    ::Todos::List.call(status: params[:status], user_id: current_user.id)
      .then(::Todos::BatchSerializeAsJson)
      .on_success { |result| render status: 200, json: { todos: result[:todos] } }
  end

  def create
    input = {
      user_id: current_user.id,
      title: todo_params[:title],
      due_at: todo_params[:due_at]
    }

    ::Todos::Create.call(input)
      .then(::Todos::SerializeAsJson)
      .on_failure(:unprocessable_entity) { |result| render status: 422, json: { todo: result[:todo] } }
      .on_success { |result| render status: 201, json: { todo: result[:todo] } }

  rescue ActionController::ParameterMissing => exception
    render_bad_request(exception.message)
  end

  def show
    ::Todos::Find.call(id: params[:id], user_id: current_user.id)
      .then(::Todos::SerializeAsJson)
      .on_failure(:not_found) { |result| render_not_found(result[:todo]) }
      .on_success { |result| render status: 200, json: { todo: result[:todo] } }
  end

  def destroy
    ::Todos::Find.call(id: params[:id], user_id: current_user.id)
      .then(::Todos::Destroy)
      .then(::Todos::SerializeAsJson)
      .on_failure(:not_found) { |result| render_not_found(result[:todo]) }
      .on_success { |result| render status: 200, json: { todo: result[:todo] } }
  end

  def update
    input = { 
      id: params[:id],
      user_id: current_user.id,
      title: todo_params[:title],
      due_at: todo_params[:due_at]
    }

    ::Todos::Find.call(input)
      .then(::Todos::Update)
      .then(::Todos::SerializeAsJson)
      .on_failure(:not_found) { |result| render_not_found(result[:todo]) }
      .on_failure(:unprocessable_entity) { |result| render status: 422, json: { todo: result[:todo] } }
      .on_success { |result| render status: 200, json: { todo: result[:todo] } }

  rescue ActionController::ParameterMissing => exception
    render_bad_request(exception.message)
  end

  def complete
    ::Todos::Find.call(id: params[:id], user_id: current_user.id)
      .then(::Todos::Complete)
      .then(::Todos::SerializeAsJson)
      .on_failure(:not_found) { |result| render_not_found(result[:todo]) }
      .on_success { |result| render status: 200, json: { todo: result[:todo] } }
  end

  def uncomplete
    ::Todos::Find.call(id: params[:id], user_id: current_user.id)
      .then(::Todos::Uncomplete)
      .then(::Todos::SerializeAsJson)
      .on_failure(:not_found) { |result| render_not_found(result[:todo]) }
      .on_success { |result| render status: 200, json: { todo: result[:todo] } }
  end

  private

    def todo_params
      params.require(:todo).permit(:title, :due_at)
    end

    def render_bad_request(message)
      render status: 400, json: { error: message }
    end

    def render_not_found(todo)
      render status: 404, json: { todo: todo }
    end
end
