class Meeting < ApplicationRecord
  belongs_to :organization
  belongs_to :creator, class_name: "User"

  has_many :tasks, dependent: :destroy

  has_one_attached :audio_file

  enum :status, { scheduled: 0, completed: 1, cancelled: 2 }

  # Only check for audio file changes if it's attached, to avoid unnecessary resets
  before_save :mark_audio_changed, if: :audio_file_attached_and_changed?

  after_commit :enqueue_ai_processing, if: :audio_changed?

  private

  def audio_file_attached_and_changed?
    audio_file.attached? && audio_file.attachment&.changed?
  end

  # We use an instance variable to track if the audio file was changed during this transaction
  def audio_changed?
    @audio_changed
  end

  def mark_audio_changed
    @audio_changed = true
  end

  def enqueue_ai_processing
    update_columns(
      ai_processed: false,
      transcript: nil,
      ai_summary: nil
    )

    ProcessMeetingAiJob.perform_later(id)
  end
end
