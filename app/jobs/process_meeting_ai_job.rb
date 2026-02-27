class ProcessMeetingAiJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 0

  def perform(meeting_id)
    meeting = Meeting.find(meeting_id)

    return unless meeting
    return unless meeting.audio_file.attached?
    return if meeting.ai_processed?

    Rails.logger.info "Starting AI processing for Meeting ID: #{meeting.id}"

    # Simulate AI processing (replace with actual AI logic)
    sleep(5) # Simulating time-consuming processing

    transcript = SpeechToTextService.new(meeting).call

    meeting.update_column(:transcript, transcript)

    OllamaTaskExtractionService.new(meeting).call

    meeting.update_column(:ai_processed, true)

  rescue => e
    Rails.logger.error("AI Processing Failed for  Meeting #{metting.id}: #{e.message}")
  end
end
