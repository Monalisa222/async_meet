require 'rails_helper'

RSpec.describe OllamaTaskExtractionService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }

  let(:meeting) do
    create(:meeting,
      organization: organization,
      creator: user,
      transcript: "Discuss roadmap and assign tasks."
    )
  end

  describe '#call' do
    it 'returns nil if transcript is missing' do
      meeting.update(transcript: nil)

      service = described_class.new(meeting)
      expect(service.call).to be_nil
    end

    it 'saves summary and tasks when valid JSON is returned' do
      parsed_json = {
        "summary" => "Roadmap discussion summary",
        "tasks" => [
          { "title" => "Prepare roadmap", "description" => "Create Q3 roadmap" },
          { "title" => "Client follow-up", "description" => "Email client" }
        ]
      }

      allow_any_instance_of(described_class)
        .to receive(:generate_with_ollama)
        .and_return("raw json")

      allow_any_instance_of(described_class)
        .to receive(:extract_json)
        .and_return("{ \"summary\": \"Roadmap discussion summary\", \"tasks\": [] }")

      allow_any_instance_of(described_class)
        .to receive(:safe_parse_json)
        .and_return(parsed_json)

      allow_any_instance_of(described_class)
        .to receive(:unload_model)

      service = described_class.new(meeting)

      expect {
        service.call
      }.to change { meeting.reload.tasks.count }.by(2)

      expect(meeting.reload.ai_summary)
        .to eq("Roadmap discussion summary")
    end

    it 'does nothing if JSON parsing fails' do
      allow_any_instance_of(described_class)
        .to receive(:generate_with_ollama)
        .and_return("invalid")

      allow_any_instance_of(described_class)
        .to receive(:extract_json)
        .and_return(nil)

      allow_any_instance_of(described_class)
        .to receive(:unload_model)

      service = described_class.new(meeting)

      expect {
        service.call
      }.not_to change { meeting.reload.tasks.count }
    end

    it 'always unloads model after execution' do
      allow_any_instance_of(described_class)
        .to receive(:generate_with_ollama)
        .and_return(nil)

      expect_any_instance_of(described_class)
        .to receive(:unload_model)

      described_class.new(meeting).call
    end
  end
end
