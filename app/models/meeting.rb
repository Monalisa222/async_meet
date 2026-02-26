class Meeting < ApplicationRecord
  belongs_to :organization
  belongs_to :creator, class_name: "User"

  has_many :tasks, dependent: :destroy

  has_one_attached :audio_file

  enum :status, { scheduled: 0, completed: 1, cancelled: 2 }

  after_commit :enqueue_ai_processing, on: [ :create, :update ]

  private

  def audio_file_attached_and_not_processed?
    audio_file.attached? && !ai_processed?
  end

  def enqueue_ai_processing
    return unless audio_file.attached?

    return if ai_processed?

    ProcessMeetingAiJob.perform_later(id)
  end
end
