AsyncMeet

AsyncMeet is a multi-tenant AI-powered meeting assistant built with Ruby on Rails.

It allows organizations to record meetings, generate AI transcripts, produce summaries, and automatically extract actionable tasks using local AI (Whisper + Ollama).

This project demonstrates production-safe AI integration inside a scalable SaaS architecture.

---

## 🚀 Core Features

### Multi-Tenant Architecture
- Organizations with isolated data
- Membership-based access control
- Owner / Member roles
- Cross-tenant protection

### Meetings
- Create, edit, and manage meetings
- Upload audio recordings
- Store transcript and AI summary
- Background AI processing

### Tasks
- Create tasks manually
- Auto-generate tasks from AI
- Optional task assignment
- Status & priority tracking
- AI-generated task tagging

### AI Capabilities
- Local speech-to-text transcription (Whisper)
- Local LLM summary generation (Ollama)
- Automatic task extraction
- Background processing via Sidekiq
- Temporary file cleanup after processing

---

## 🧠 Why Local AI?

We use local AI instead of cloud APIs for:

- No API cost
- Offline functionality
- Data privacy
- Full system control
- Demo-friendly setup

Architecture allows easy switching to cloud providers later without changing UI or database structure.

---

## 🏗 System Architecture

### Tech Stack

- Ruby on Rails 8
- PostgreSQL
- Redis
- Sidekiq (Background Jobs)
- ActiveStorage
- Whisper (CPU-only)
- Ollama (phi3:mini model)

---

### AI Processing Flow

1. User uploads meeting audio
2. ActiveStorage stores file
3. Sidekiq job starts processing
4. Whisper generates transcript
5. Transcript saved in database
6. Ollama processes transcript
7. AI summary generated
8. Actionable tasks extracted
9. Tasks saved as `ai_generated = true`
10. Temporary files deleted

All AI runs asynchronously to avoid blocking HTTP requests.

---

## 🔐 Multi-Tenant Security Model

- Every Meeting belongs to an Organization
- Every Task belongs to Meeting and Organization
- Membership required to access organization data
- Owner role restrictions implemented
- Strong parameter validation
- Background job tenant scoping
- No cross-tenant data leakage

---

## 📦 Installation Guide

### 1. Clone Repository

```

git clone https://github.com/Monalisa222/async_meet.git
cd async_meet
bundle install

```

---

### 2. Setup Database

```

rails db:create
rails db:migrate

```

---

### 3. Install Redis

```

sudo apt install redis-server
sudo systemctl start redis

```

---

### 4. Install ffmpeg

Whisper requires ffmpeg:

```

sudo apt install ffmpeg

```

Verify:

```

ffmpeg -version

```

---

### 5. Install Whisper (CPU Version)

Install CPU-only PyTorch:

```

pip3 install --user torch --index-url [https://download.pytorch.org/whl/cpu](https://download.pytorch.org/whl/cpu)

```

Install Whisper:

```

pip3 install --user openai-whisper

```

Add to PATH (one-time setup):

```

echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

```

Verify installation:

```

whisper --help

```

---

### 6. Install Ollama

Download from:

https://ollama.com

Pull lightweight model:

```

ollama pull phi3:mini

```

This model is optimized for low CPU and demo environments.

---

### 7. Start Application

Terminal 1 (Background Jobs):

bundle exec sidekiq

Terminal 2 (Rails Server):

rails server

Visit:

http://localhost:3000

## 🧹 File Cleanup Strategy

Whisper can generate multiple file formats:
- .txt
- .json
- .vtt
- .srt

AsyncMeet:
- Forces output to `/tmp`
- Uses only `.txt`
- Deletes all temporary files after processing
- Prevents disk clutter

---

## ⚡ Why Background Jobs?

AI processing is CPU-intensive.

Sidekiq ensures:
- No request blocking
- Smooth user experience
- Automatic retries
- Clean separation of concerns
- Scalable architecture

---

## 🛠 Service Architecture

### SpeechToTextService
- Downloads audio to `/tmp`
- Runs Whisper CLI
- Reads transcript
- Cleans temporary files

### OllamaTaskExtractionService
- Sends transcript to local LLM
- Forces strict JSON response
- Generates summary
- Extracts actionable tasks
- Saves tasks with AI flag

---

## 📊 Project Status

- Multi-tenant system complete
- Meeting management complete
- Task lifecycle complete
- Background job processing complete
- AI transcription working
- AI summary working
- AI task extraction working
- Temporary file cleanup implemented
- Demo-ready system

---

## 🎯 Purpose of This Project

AsyncMeet demonstrates:

- Real AI integration in Rails
- Background job architecture
- Local LLM integration
- Production-safe multi-tenant SaaS design
- Clean service-based architecture
- AI-powered task automation workflow
