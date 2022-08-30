# frozen_string_literal: true

class TodosController < ApplicationController
  before_action :authenticate_user

  before_action :set_todo, only: %i[show destroy update complete uncomplete]

  rescue_from ActiveRecord::RecordNotFound do
    render_json(404, todo: { id: 'not found' })
  end

  def index
    todos =
      case params[:status]&.strip&.downcase
      when 'overdue' then Todo.overdue
      when 'completed' then Todo.completed
      when 'uncompleted' then Todo.uncompleted
      else Todo.all
      end

    json = todos.where(user_id: current_user.id).map(&:serialize_as_json)

    render_json(200, todos: json)
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
    render_json(200, todo: @todo.serialize_as_json)
  end

  def destroy
    @todo.destroy

    render_json(200, todo: @todo.serialize_as_json)
  end

  def update
    @todo.update(todo_params)

    if @todo.valid?
      render_json(200, todo: @todo.serialize_as_json)
    else
      render_json(422, todo: @todo.errors.as_json)
    end
  end

  def complete
    ::Todos::Complete.call(id: params[:id], user_id: current_user.id) do |on|
      on.failure(:not_found) { |result| render status: 404, json: { todo: result[:todo] } }
      on.success { |result| render status: 200, json: { todo: result[:todo] } }
    end
  end

  def uncomplete
    @todo.uncomplete!

    render_json(200, todo: @todo.serialize_as_json)
  end

  private

    def todo_params
      params.require(:todo).permit(:title, :due_at)
    end

    def set_todo
      @todo = current_user.todos.find(params[:id])
    end
end
