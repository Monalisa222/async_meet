class TasksController < ApplicationController
  before_action :require_organization
  before_action :set_meeting
  before_action :set_task, only: [ :edit, :update, :destroy ]

  def create
    @task = @meeting.tasks.new(task_params)
    @task.organization = current_organization

    if @task.save
      redirect_to meeting_path(@meeting), notice: "Task was successfully created."
    else
      redirect_to meeting_path(@meeting), alert: @task.errors.full_messages.to_sentence
    end
  end

  def edit; end

  def update
    if @task.update(task_params)
      redirect_to meeting_path(@meeting), notice: "Task was successfully updated."
    else
      flash.now[:alert] = @task.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to meeting_path(@meeting), notice: "Task was successfully deleted."
  end

  private

  def set_meeting
    @meeting = current_organization.meetings.find(params[:meeting_id])
  end

  def set_task
    @task = @meeting.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :assigned_user_id, :due_date, :priority, :status)
  end
end
