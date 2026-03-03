require 'rails_helper'

RSpec.describe ProcessMeetingAiJob, type: :job do
  include ActiveJob::TestHelper

  let(:organization) { create(:organization) }
  let(:user) { create(:user) }

  let(:meeting) do
    create(:meeting,
      organization: organization,
      creator: user,
      ai_processed: false
    )
  end

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  def attach_audio(meeting)
    file = fixture_file_upload(
      Rails.root.join('spec/fixtures/files/project_audio.wav'),
      'audio/mpeg'
    )
    meeting.audio_file.attach(file)
  end

  describe 'enqueueing' do
    it 'enqueues on default queue' do
      expect {
        described_class.perform_later(meeting.id)
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end

  describe '#perform' do
    it 'does nothing if meeting not found' do
      expect {
        described_class.perform_now(999999)
      }.not_to raise_error
    end

    it 'does nothing if no audio attached' do
      described_class.perform_now(meeting.id)
      expect(meeting.reload.transcript).to be_nil
    end

    it 'does nothing if already processed' do
      attach_audio(meeting)
      meeting.update_column(:ai_processed, true)

      described_class.perform_now(meeting.id)

      expect(meeting.reload.transcript).to be_nil
    end

    it 'processes transcript and summary when valid' do
      attach_audio(meeting)

      allow_any_instance_of(SpeechToTextService)
        .to receive(:call)
        .and_return("Test transcript")

      allow_any_instance_of(OllamaTaskExtractionService)
        .to receive(:call)
        .and_return(true)

      described_class.perform_now(meeting.id)

      meeting.reload

      expect(meeting.transcript).to eq("Test transcript")
      expect(meeting.ai_processed).to be true
    end

    it 'aborts if audio changes during processing' do
      attach_audio(meeting)

      allow_any_instance_of(SpeechToTextService)
        .to receive(:call) do
          # simulate audio change during processing
          meeting.audio_file.attach(
            fixture_file_upload(
              Rails.root.join('spec/fixtures/files/project_audio.wav'),
              'audio/mpeg'
            )
          )
          "Transcript"
        end

      described_class.perform_now(meeting.id)

      meeting.reload
      expect(meeting.ai_processed).to be false
    end

    it 'handles errors and resets ai_processed' do
      attach_audio(meeting)

      allow_any_instance_of(SpeechToTextService)
        .to receive(:call)
        .and_raise(StandardError.new("Boom"))

      described_class.perform_now(meeting.id)

      meeting.reload
      expect(meeting.ai_processed).to be false
    end
  end
end
