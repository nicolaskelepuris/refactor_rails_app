# frozen_string_literal: true

class TodosController < ApplicationController
  before_action :authenticate_user

  before_action :set_todo, only: %i[show destroy update complete uncomplete]

  rescue_from ActiveRecord::RecordNotFound do
    render_json(404, todo: { id: 'not found' })
  end

  def index
    ::Todos::List.call(status: params[:status], user_id: current_user.id) do |on|
      on.success { |result| render status: 200, json: { todos: result[:todos] } }
    end
  end

  def create
    input = {
      user_id: current_user.id,
      title: todo_params[:title],
      due_at: todo_params[:due_at]
    }
    ::Todos::Create.call(input) do |on|
      on.failure(:unprocessable_entity) { |result| render status: 422, json: { todo: result[:todo] } }
      on.success { |result| render status: 201, json: { todo: result[:todo] } }
    end
  end

  def show
    ::Todos::Find.call(id: params[:id], user_id: current_user.id) do |on|
      on.failure(:not_found) { |result| render status: 404, json: { todo: result[:todo] } }
      on.success { |result| render status: 200, json: { todo: result[:todo] } }
    end
  end

  def destroy
    ::Todos::Destroy.call(id: params[:id], user_id: current_user.id) do |on|
      on.failure(:not_found) { |result| render status: 404, json: { todo: result[:todo] } }
      on.success { |result| render status: 200, json: { todo: result[:todo] } }
    end
  end

  def update
    input = { 
      id: params[:id],
      user_id: current_user.id,
      title: todo_params[:title],
      due_at: todo_params[:due_at]
    }
    ::Todos::Update.call(input) do |on|
      on.failure(:not_found) { |result| render status: 404, json: { todo: result[:todo] } }
      on.failure(:unprocessable_entity) { |result| render status: 422, json: { todo: result[:todo] } }
      on.success { |result| render status: 200, json: { todo: result[:todo] } }
    end
  end

  def complete
    ::Todos::Complete.call(id: params[:id], user_id: current_user.id) do |on|
      on.failure(:not_found) { |result| render status: 404, json: { todo: result[:todo] } }
      on.success { |result| render status: 200, json: { todo: result[:todo] } }
    end
  end

  def uncomplete
    ::Todos::Uncomplete.call(id: params[:id], user_id: current_user.id) do |on|
      on.failure(:not_found) { |result| render status: 404, json: { todo: result[:todo] } }
      on.success { |result| render status: 200, json: { todo: result[:todo] } }
    end
  end

  private

    def todo_params
      params.require(:todo).permit(:title, :due_at)
    end

    def set_todo
      @todo = current_user.todos.find(params[:id])
    end
end
