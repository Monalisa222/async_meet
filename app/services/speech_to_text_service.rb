require "securerandom"

class SpeechToTextService
  def initialize(meeting)
    @meeting = meeting
  end

  def call
    return unless @meeting.audio_file.attached?

    audio_path = download_audio
    begin
      transcript = transcribe(audio_path)
      transcript
    ensure
      cleanup_files(audio_path) if audio_path.present?
    end
  end

  private

  def download_audio
    extension = @meeting.audio_file.blob.filename.extension
    file_path = Rails.root.join(
      "tmp",
      "meeting_#{@meeting.id}_#{SecureRandom.hex(6)}.#{extension}"
    )

    File.binwrite(file_path, @meeting.audio_file.download)

    file_path.to_s
  end

  def transcribe(file_path)
    base_name  = File.basename(file_path, ".*")
    output_dir = Rails.root.join("tmp").to_s
    output_path = File.join(output_dir, "#{base_name}.txt")

    whisper = ENV["WHISPER_PATH"]

    success = system("#{whisper} #{file_path} --model base --output_format txt --output_dir #{output_dir}")

    return unless success && File.exist?(output_path)

    File.read(output_path)
  end

  def cleanup_files(file_path)
    base_name = File.basename(file_path, ".*")
    dir       = Rails.root.join("tmp")

    # Delete ALL files generated for this meeting (audio + txt + vtt + srt + json etc.)
    Dir.glob(dir.join("#{base_name}.*")).each do |file|
      File.delete(file) if File.exist?(file)
    end
  end
end
