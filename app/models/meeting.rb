class Meeting < ApplicationRecord
  belongs_to :organization
  belongs_to :creator, class_name: "User"

  has_many :tasks, dependent: :destroy

  has_one_attached :audio_file

  enum :status, { scheduled: 0, completed: 1, cancelled: 2 }

  # Detect new audio BEFORE saving
  before_save :reset_ai_if_audio_replaced

  after_commit :enqueue_ai_processing, if: :should_process_ai?

  private

  def should_process_ai?
    audio_file.attached? && !ai_processed?
  end

  def enqueue_ai_processing
    ProcessMeetingAiJob.perform_later(id)
  end

  # IF a new audio file is attached during update,
  # reset AI-related fields so it rerun job

  def reset_ai_if_audio_replaced
    return unless audio_file.attached?
    return unless audio_file.attachment&.changed?

    self.ai_processed = false
    self.transcript = nil
    self.ai_summary = nil
  end
end
