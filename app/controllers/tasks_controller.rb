class TasksController < ApplicationController
  before_action :require_organization

  def create
    @meeting = current_organization.meetings.find(params[:meeting_id])
    @task = @meeting.tasks.new(task_params)
    @task.organization = current_organization

    if @task.save
      redirect_to meeting_path(@meeting), notice: "Task was successfully created."
    else
      redirect_to meeting_path(@meeting), alert: @task.errors.full_messages.to_sentence
    end
  end
  
  private

  def task_params
    params.require(:task).permit(:title, :description, :assigned_user_id, :due_date, :priority, :status)
  end
end
