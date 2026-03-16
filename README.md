# LingoLearn

LingoLearn is a hackathon language-learning app built around one core idea: learners should not all start at the same place.

Unlike a fixed beginner-first experience, this demo asks the learner to rate their German level first, then generates chapter content for that level using Amazon Nova. The current implementation uses a Flutter frontend, a FastAPI backend, and Amazon Bedrock / Nova for AI-powered tutoring flows.

## Problem Statement

Most language apps give every learner the same starting point, even when they already know part of the language.

LingoLearn is designed to improve that experience by:

- asking the learner where they currently are
- generating lessons at that level
- tracking chapter performance
- deciding whether the learner should move up, retry, or finish the journey

## Demo Experience

The current demo is focused on German for English-speaking learners.

Flow:

1. Login with the seeded demo account.
2. Choose a German self-rating on a 5-level slider.
3. Start in chapter 5 of the selected level.
4. Complete 3 generated lessons.
5. Receive a level outcome based on performance.

### Level Names

- Level 1: `Newbie`
- Level 2: `Beginner`
- Level 3: `Intermediate`
- Level 4: `Advanced`
- Level 5: `Expert`

### Demo Progression Rules

- For the demo, chapters 1-4 are treated as already completed.
- The learner starts in chapter 5 of the selected level.
- Chapters 1-4 are pre-seeded with average scores.
- The seeded average is currently `85%`.
- Chapter 5 is made up of 3 fresh generated lessons.
- Chapter 5 lessons start as `Pending` and only receive scores after completion.
- Final level progression uses the combined 5-chapter average:
  - `>= 80%`: promote
  - `50-79.9%`: reset same level with fresh retry content
  - `< 50%`: relegate when possible
  - Level 5 with passing score: `Mastered!`

## Current Learning Experience

Each lesson is structured as:

1. `Learn`
2. `Practice`
3. `Reading`
4. `Listening`
5. `Writing`
6. `Speaking`
7. `Assessment`

The app is designed around `teach first, test later`.

### Learning features

- Learn phase with explicit instruction before testing
- Mini-dialogue content with English translation
- Vocabulary teaching with examples
- Grammar tip and coaching tip
- Translation-aware learner text across lesson screens
- Word-by-word English gloss support
- Full-phrase English translation support

### Practice features

- Practice is unscored before the final assessment
- Practice includes submit and retry behavior
- Learners can move forward after submitting once
- Reading, listening, writing, and speaking practice screens do not affect official scores

### Assessment features

- Final assessment is scored separately from practice
- Assessment includes:
  - reading assessment
  - listening assessment
  - writing assessment
  - speaking assessment
  - 5 MCQ questions
- Assessment is aligned with the same vocabulary and theme as the earlier lesson practice

### Feedback and retry features

- Long-form feedback after lesson completion
- `What went well` and `What to improve` summaries
- Correct-answer review after assessment
- Completed lessons can be retried from the dashboard
- Retry does not overwrite the official completed score

### Adaptive progression features

- Full-level progression based on the average across 5 chapters
- Weakness-aware reset generation based on prior attempts
- Persisted feedback used to bias reset content toward weak topics, weak words, and weak skills

### AI features

- Amazon Nova-backed doubt chatbot for German-language questions
- Amazon Nova-backed evaluation and AI-assisted generation paths
- Nova-first lesson generation path with safe local fallback so the demo remains stable if a live generation call fails

## What Changed In This Build

This repo started as a simpler prototype and was upgraded significantly during the build sessions for the hackathon demo.

### Frontend changes

- Reworked the app into a cleaner mobile-first Flutter flow
- Added a login -> level selection -> loading -> dashboard journey
- Replaced static placeholder screens with backend-driven lesson, progress, profile, and flashcard data
- Added a dedicated level selector with named proficiency levels
- Added colorful lesson cards and improved dashboard visuals
- Added chapter result dialogs for `Promoted`, `Reset`, `Relegated`, and `Mastered`
- Updated lesson flow screens for Learn, Practice, Reading, Listening, Writing, Speaking, and Assessment
- Added translation-aware lesson presentation
- Added completed-lesson retry flow from the dashboard
- Added a doubt-chat screen connected to the backend

### Backend changes

- Added `.env` validation for Amazon Bedrock / Nova-backed generation
- Added startup checks for Nova / Bedrock configuration
- Switched the backend from a simple lesson prototype to a level-aware chapter model
- Added placement logic so the learner can pick a level after login
- Added progression state for level, chapter, and chapter outcomes
- Added generated lesson content for the current chapter using Amazon Nova with a safe local fallback path
- Added progress, profile, and flashcard endpoints for the frontend
- Added AI-backed assessment evaluation with fallback behavior
- Added local development CORS handling for Flutter web
- Added a doubt-chat endpoint
- Added detailed lesson feedback and richer assessment result payloads
- Added reset-focus profiling from prior attempts

### Integration and demo hardening

- Connected Flutter to the FastAPI backend through a real API client
- Verified local login and backend app-data flows
- Fixed multiple live issues found during browser testing, including fetch and stale-progress bugs
- Updated seeded progress so chapter 5 starts pending while earlier chapters remain completed
- Added fallback lesson generation so placement does not fail when live Nova lesson generation is unstable

## Tech Stack

### Frontend

- Flutter
- Dart
- Material UI
- `http` for API calls

Main frontend app:

- [`front_end`](/c:/Studies%20and%20Applications/Projects/language-tutor/front_end)

### Backend

- Python 3.12
- FastAPI
- Uvicorn
- Pydantic
- LangChain
- Amazon Bedrock / Nova

Main backend app:

- [`backend/app`](/c:/Studies%20and%20Applications/Projects/language-tutor/backend/app)

## Project Structure

```text
language-tutor/
|-- backend/
|   `-- app/
|       |-- api/routes/
|       |-- chains/
|       |-- core/
|       |-- db/
|       |-- llm/
|       |-- prompts/
|       |-- schemas/
|       `-- services/
|-- front_end/
|   `-- lib/
|       |-- models/
|       |-- pages/
|       |-- services/
|       |-- state/
|       `-- widgets/
|-- .env
|-- pyproject.toml
`-- README.md
```

## Key Backend Capabilities

### Authentication

- Demo login is stored in memory
- Demo credentials:
  - Email: `hari@example.com`
  - Password: `demo123`

### Placement and learner state

- After login, the learner selects a level
- The backend stores the selected level as the active demo state
- The learner is placed into chapter 5 of that level
- Lesson, attempt, and flashcard state is reset for the new demo session

### Lesson generation

- Lessons are generated through Amazon Nova via LangChain where available
- If a live Nova lesson-generation call fails, the backend falls back to a deterministic template builder using the same lesson schema
- Generation is conditioned on:
  - selected level
  - chapter number
  - grammar focus
  - vocabulary focus
  - target language

### Lesson schema

The backend lesson package includes:

- `card`
- `learn`
- `practice`
- `reading`
- `listening`
- `writing`
- `speaking`
- `assessment`

### Progress and evaluation

- Chapters 1-4 are seeded for the demo
- Chapter 5 is generated dynamically
- Assessment results update lesson and level outcomes
- The backend returns long feedback, strengths, weaknesses, and correct answers
- The backend returns level outcomes such as promoted, reset, relegated, or mastered

## Key Frontend Capabilities

- Login screen for the demo account
- Level-selection screen after login
- Loading step that fetches app state from the backend
- Dashboard with lesson feed, progress, profile, and flashcards
- Lesson flow covering Learn, Practice, Reading, Listening, Writing, Speaking, and Assessment
- Translation reveal controls for learner-facing German text
- Result dialogs after the final lesson is completed
- Doubt-chat page for German language questions
- Completed-lesson retry support

## API Summary

Main routes currently used by the demo:

- `POST /auth/login`
- `POST /app/placement`
- `GET /lessons?user_id=...`
- `GET /lessons/{lesson_id}/learn`
- `GET /lessons/{lesson_id}/practice`
- `GET /lessons/{lesson_id}/reading`
- `GET /lessons/{lesson_id}/listening`
- `GET /lessons/{lesson_id}/writing`
- `GET /lessons/{lesson_id}/speaking`
- `GET /lessons/{lesson_id}/assessment`
- `POST /lessons/{lesson_id}/submit-assessment`
- `GET /app/progress?user_id=...`
- `GET /app/profile?user_id=...`
- `GET /app/flashcards?user_id=...`
- `POST /app/doubt-chat`

Swagger docs:

- `http://127.0.0.1:8000/docs`

## Environment Setup

Create a `.env` file in the project root.

For Amazon Nova on Bedrock:

```env
LLM_PROVIDER=nova
AWS_REGION=your_aws_region
AWS_PROFILE=your_optional_local_aws_profile
BEDROCK_MODEL_ID=your_nova_model_id_or_inference_profile
```

You can also use `LLM_PROVIDER=bedrock` with the same Bedrock variables.

The backend validates this configuration on startup and rejects missing provider settings.

## Run Locally

### Start the backend

From the project root:

```powershell
python -m uvicorn backend.app.main:app --host 127.0.0.1 --port 8000
```

### Start the frontend

From [`front_end`](/c:/Studies%20and%20Applications/Projects/language-tutor/front_end):

```powershell
flutter run -d chrome
```

## Demo Walkthrough

1. Open the Flutter web app in Chrome.
2. Sign in with `hari@example.com` and `demo123`.
3. Choose a German proficiency level.
4. Click `Let's start!`
5. Complete the 3 generated lessons for chapter 5.
6. Work through Learn, Practice, Reading, Listening, Writing, and Speaking.
7. Submit the final assessment.
8. Review the resulting progress, profile, feedback, and level outcome.

## Current Limitations

- Data is still in-memory for the hackathon demo
- Restarting the backend resets the active demo state
- The demo currently focuses on German only
- The progression model is intentionally simplified for presentation
- Speaking and listening audio remain lightweight/demo-oriented for now
- This project is currently intended for local demo use, not public deployment

## Why This Project Matters

LingoLearn is not trying to be a full Duolingo clone. The pitch is narrower and more specific:

- adaptive entry point instead of a one-size-fits-all beginner start
- teach-first lesson flow based on learner level
- progression that reacts to learner performance
- retry and remediation that preserve score integrity
- a smoother, more personalized first experience

For the hackathon, this repo demonstrates that idea end-to-end with a working Flutter UI, a FastAPI backend, and Amazon Nova-powered German tutoring flows.
