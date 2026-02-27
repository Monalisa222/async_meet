require "net/http"
require "json"
require "uri"

class OllamaTaskExtractionService
  OLLAMA_URL = "http://127.0.0.1:11434/api/generate"
  MODEL_NAME = "phi3:mini"

  def initialize(meeting)
    @meeting = meeting
  end

  def call
    return unless @meeting.transcript.present?

    Rails.logger.info "[OLLAMA] Processing Meeting ##{@meeting.id}"

    prompt = build_prompt(@meeting.transcript)

    raw_output = generate_with_ollama(prompt)
    return unless raw_output.present?

    cleaned_json = extract_json(raw_output)
    return unless cleaned_json.present?

    parsed = safe_parse_json(cleaned_json)
    return unless parsed

    save_results(parsed)

  rescue => e
    Rails.logger.error "[OLLAMA ERROR] Meeting ##{@meeting.id} - #{e.message}"

  ensure
    unload_model
  end

  private

  # ---------------------------
  # Prompt
  # ---------------------------
  def build_prompt(transcript)
    <<~PROMPT
    You are a strict JSON generator.

    Output must be valid JSON.
    Do NOT include markdown.
    Do NOT include explanations.
    Do NOT include backticks.
    Do NOT include comments.
    Do NOT include extra text before or after JSON.

    The output must:
    - Be minified (single line JSON).
    - Use double quotes only.
    - Contain no control characters.
    - Contain no trailing commas.

    Format:
    {
      "summary": "...",
      "tasks": [
        { "title": "...", "description": "..." }
      ]
    }

    Transcript:
    #{transcript}
    PROMPT
  end

  # ---------------------------
  # Ollama HTTP Call
  # ---------------------------
  def generate_with_ollama(prompt)
    Rails.logger.info "[OLLAMA] Sending request (model: #{MODEL_NAME})"

    uri = URI(OLLAMA_URL)

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"

    request.body = {
      model: MODEL_NAME,
      prompt: prompt,
      stream: false,
      options: {
        num_ctx: 512,
        temperature: 0.2
      }
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.read_timeout = 300
      http.request(request)
    end

    parsed_response = JSON.parse(response.body)

    Rails.logger.info "[OLLAMA] Response received"

    parsed_response["response"]

  rescue => e
    Rails.logger.error "[OLLAMA ERROR] HTTP Request Failed - #{e.message}"
    nil
  end

  # ---------------------------
  # Remove markdown & extract JSON
  # ---------------------------
  def extract_json(raw_output)
    cleaned = raw_output.gsub(/```json|```/, "").strip
    match = cleaned.match(/\{.*\}/m)

    unless match
      Rails.logger.warn "[OLLAMA] JSON block not found in response"
      return nil
    end

    match[0]
  end

  # ---------------------------
  # Safe JSON parsing
  # ---------------------------
  def safe_parse_json(json_string)
    parsed = JSON.parse(json_string)
    Rails.logger.info "[OLLAMA] JSON parsed successfully"
    parsed
  rescue JSON::ParserError => e
    Rails.logger.error "[OLLAMA ERROR] JSON Parse Failed - #{e.message}"
    nil
  end

  # ---------------------------
  # Save Summary & Tasks
  # ---------------------------
  def save_results(parsed)
    @meeting.update(ai_summary: parsed["summary"])

    tasks = parsed["tasks"] || []
    saved_count = 0

    tasks.each do |task|
      next unless task["title"].present?

      @meeting.tasks.create(
        title: task["title"],
        description: task["description"] || "",
        status: :pending,
        priority: :medium,
        ai_generated: true,
        organization: @meeting.organization
      )

      saved_count += 1
    end

    Rails.logger.info "[OLLAMA] Saved #{saved_count} tasks for Meeting ##{@meeting.id}"
  end

  # ---------------------------
  # Free Memory After Use
  # ---------------------------
  def unload_model
    Rails.logger.info "[OLLAMA] Unloading model #{MODEL_NAME}"
    system("ollama stop #{MODEL_NAME}")
  end
end
