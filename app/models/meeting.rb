class Meeting < ApplicationRecord
  belongs_to :organization
  belongs_to :creator, class_name: "User"

  has_many :tasks, dependent: :destroy

  has_one_attached :audio_file

  enum :status, { scheduled: 0, completed: 1, cancelled: 2 }

  after_commit :enqueue_ai_processing, if: :should_process_ai?

  private

  def should_process_ai?
    return false unless audio_file.attached?

    previously_new_record? || attachment_changed?
  end

  def attachment_changed?
    saved_changes.key?("audio_file_attachment")
  end

  def enqueue_ai_processing
    # Reset transcript + mark unprocessed
    update_columns(
      ai_processed: false,
      transcript: nil
    )
    ProcessMeetingAiJob.perform_later(id)
  end
end
