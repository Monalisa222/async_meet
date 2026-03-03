require 'rails_helper'

RSpec.describe SpeechToTextService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }
  let(:meeting) { create(:meeting, organization: organization, creator: user) }

  def attach_audio
    file = fixture_file_upload(
      Rails.root.join('spec/fixtures/files/project_audio.wav'),
      'audio/mpeg'
    )
    meeting.audio_file.attach(file)
  end

  describe '#call' do
    it 'returns nil if no audio attached' do
      service = described_class.new(meeting)
      expect(service.call).to be_nil
    end

    it 'returns transcript when transcription succeeds' do
      attach_audio

      allow_any_instance_of(described_class)
        .to receive(:download_audio)
        .and_return("tmp/fake.mp3")

      allow_any_instance_of(described_class)
        .to receive(:transcribe)
        .and_return("Test transcript")

      allow_any_instance_of(described_class)
        .to receive(:cleanup_files)

      service = described_class.new(meeting)
      result = service.call

      expect(result).to eq("Test transcript")
    end

    it 'returns nil if transcription fails' do
      attach_audio

      allow_any_instance_of(described_class)
        .to receive(:download_audio)
        .and_return("tmp/fake.mp3")

      allow_any_instance_of(described_class)
        .to receive(:transcribe)
        .and_return(nil)

      allow_any_instance_of(described_class)
        .to receive(:cleanup_files)

      service = described_class.new(meeting)
      result = service.call

      expect(result).to be_nil
    end

    it 'always calls cleanup after execution' do
      attach_audio

      allow_any_instance_of(described_class)
        .to receive(:download_audio)
        .and_return("tmp/fake.mp3")

      allow_any_instance_of(described_class)
        .to receive(:transcribe)
        .and_return("Transcript")

      expect_any_instance_of(described_class)
        .to receive(:cleanup_files)

      described_class.new(meeting).call
    end
  end
end
