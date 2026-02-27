class ProcessMeetingAiJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 2

  def perform(meeting_id)
    meeting = Meeting.find_by(id: meeting_id)
    return unless meeting
    return unless meeting.audio_file.attached?
    return if meeting.ai_processed?

    # Capture blob id at job start (race-condition protection)
    initial_blob_id = meeting.audio_file.blob_id

    Rails.logger.info "AI started for Meeting #{meeting.id} (blob #{initial_blob_id})"

    # -----------------------------
    # Step 1: Transcription
    # -----------------------------
    transcript = SpeechToTextService.new(meeting).call
    return unless transcript.present?

    # Reload to check if audio changed during processing
    meeting.reload

    if meeting.audio_file.blob_id != initial_blob_id
      Rails.logger.warn "AI aborted for Meeting #{meeting.id} - audio changed during processing"
      return
    end

    meeting.update_column(:transcript, transcript)

    # -----------------------------
    # Step 2: Summary Extraction
    # -----------------------------
    OllamaTaskExtractionService.new(meeting).call

    # Mark as processed only at the very end
    meeting.update_column(:ai_processed, true)

    Rails.logger.info "AI completed for Meeting #{meeting.id}"

  rescue => e
    Rails.logger.error "AI failed for Meeting #{meeting_id}: #{e.message}"

    # Ensure AI can retry later
    meeting&.update_column(:ai_processed, false)
  end
end
