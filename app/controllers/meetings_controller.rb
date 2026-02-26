class MeetingsController < ApplicationController
  before_action :require_owner, only: [ :new, :create, :edit, :update ]
  before_action :require_organization

  def index
    @meetings = current_organization.meetings.order(created_at: :desc)
  end

  def show
    @meeting = current_organization.meetings.includes(:creator).find(params[:id])
  end

  def new
    @meeting = current_organization.meetings.new
  end

  def create
    @meeting = current_organization.meetings.new(meeting_params)
    @meeting.creator = current_user
    if @meeting.save
      redirect_to meetings_path, notice: "Meeting created successfully."
    else
      flash.now[:alert] = @meeting.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @meeting = current_organization.meetings.find(params[:id])
  end

  def update
    @meeting = current_organization.meetings.find(params[:id])
    if @meeting.update(meeting_params)
      redirect_to meeting_path(@meeting), notice: "Meeting updated successfully."
    else
      flash.now[:alert] = @meeting.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def meeting_params
    params.require(:meeting).permit(:title, :description, :status, :scheduled_at, :duration_minutes, :meeting_url, :audio_file)
  end
end
