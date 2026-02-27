class SpeechToTextService
  def initialize(meeting)
    @meeting = meeting
  end

  def call
    return unless @meeting.audio_file.attached?

    audio_path = download_audio
    transcript = transcribe(audio_path)
    cleanup_files(audio_path)

    transcript
  end

  private

  def download_audio
    extension = @meeting.audio_file.blob.filename.extension
    file_path = Rails.root.join("tmp", "meeting_#{@meeting.id}.#{extension}")

    File.open(file_path, "wb") do |file|
      file.write(@meeting.audio_file.download)
    end

    file_path.to_s
  end

  def transcribe(file_path)
    base_name = File.basename(file_path, ".*")
    output_path = Rails.root.join("tmp", "#{base_name}.txt").to_s
    whisper = ENV["WHISPER_PATH"]

    success = system("#{whisper} #{file_path} --model base --output_format txt --output_dir tmp")

    return unless success && File.exist?(output_path)

    File.read(output_path)
  end

  def cleanup_files(file_path)
    txt_path = file_path.sub(/\.\w+$/, ".txt")

    File.delete(file_path) if File.exist?(file_path)
    File.delete(txt_path) if File.exist?(txt_path)
  end
end
