class TasksController < ApplicationController
  load_and_authorize_resource
  before_action :set_task, only: [:show, :edit, :update, :destroy, :trigger]

  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = (current_user.owned_tasks + current_user.tasks).uniq
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  # POST /tasks.json
  def create
    params['task']['participating_users_attributes'] = delete_duplicated_participating_users(params['task']['participating_users_attributes'])

    @task = Task.new(task_params)
    @task.owner = current_user

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: 'Task was successfully created.' }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def trigger
    Tasks::TriggerEvent.new.call @task, params[:event]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.require(:task).permit(
        :name,
        :description,
        :due_date,
        :category_id,
        participating_users_attributes: [
          :user_id,
          :role,
          :id,
          :_destroy
        ]
      )
    end

    def delete_duplicated_participating_users(participating_users)
      result = {}
      participating_users.each do |key, value|
        unless (included?(value[:user_id], result))
          result[key] = value
        end
      end
      result
    end

    def included?(user_id, hash)
      return false if hash.empty?
      hash.each do |k, v|
        if (v[:user_id] == user_id)
          return true
        end
      end
      false
    end
end
