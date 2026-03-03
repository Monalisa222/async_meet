require 'rails_helper'

RSpec.describe "Meetings", type: :request do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }

  let!(:meeting) do
    create(:meeting,
      organization: organization,
      creator: user,
      title: "Weekly Sync",
      scheduled_at: Time.current,
      duration_minutes: 30
    )
  end

  before do
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user)
      .and_return(user)

    allow_any_instance_of(ApplicationController)
      .to receive(:current_organization)
      .and_return(organization)

    allow_any_instance_of(ApplicationController)
      .to receive(:require_owner)
      .and_return(true)

    allow_any_instance_of(ApplicationController)
      .to receive(:require_organization)
      .and_return(true)
  end

  describe "GET /index" do
    it "returns success and lists meetings" do
      get meetings_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Weekly Sync")
    end
  end

  describe "GET /show" do
    it "returns meeting details" do
      get meeting_path(meeting)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    it "creates a new meeting when valid" do
      expect {
        post meetings_path, params: {
          meeting: {
            title: "New Meeting",
            description: "Planning session",
            scheduled_at: Time.current,
            duration_minutes: 45
          }
        }
      }.to change(Meeting, :count).by(1)

      expect(response).to redirect_to(meetings_path)
    end

    it "does not create meeting when invalid" do
      expect {
        post meetings_path, params: {
          meeting: {
            title: nil,
            scheduled_at: Time.current
          }
        }
      }.not_to change(Meeting, :count)
    end
  end

  describe "PATCH /update" do
    it "updates meeting successfully" do
      patch meeting_path(meeting), params: {
        meeting: {
          title: "Updated Title",
          scheduled_at: Time.current
        }
      }

      expect(response).to redirect_to(meeting_path(meeting))
      expect(meeting.reload.title).to eq("Updated Title")
    end

    it "does not update when invalid" do
      original_title = meeting.title

      patch meeting_path(meeting), params: {
        meeting: {
          title: nil,
          scheduled_at: Time.current
        }
      }

      expect(meeting.reload.title).to eq(original_title)
    end
  end
end
