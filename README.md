# LingoLearn

LingoLearn is a hackathon language-learning app built around one core idea: learners should not all start at the same place.

Unlike a fixed beginner-first experience, this demo asks the learner to rate their German level first, then generates chapter content for that level using an LLM. The current implementation uses a Flutter frontend, a FastAPI backend, and OpenAI-backed lesson generation and evaluation.

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
5. Receive a chapter result based on performance.

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
- Chapter 5 is made up of 3 fresh LLM-generated lessons.
- Chapter 5 lessons start as `Pending` and only receive scores after completion.
- If the learner clears the chapter threshold, they are promoted to the next level.
- If they pass at level 5, the app shows `Mastered!`
- If they do not pass, they stay on the same level and retry

The current backend implementation uses a `60%` chapter threshold for the chapter-5 promotion decision.

## What Changed In This Build

This repo started as a simpler prototype and was upgraded significantly during this build session.

### Frontend changes

- Reworked the app into a cleaner mobile-first Flutter flow
- Added a login -> level selection -> loading -> dashboard journey
- Replaced static placeholder screens with backend-driven lesson, progress, profile, and flashcard data
- Added a dedicated level selector with named proficiency levels
- Added chapter result dialogs for `Promoted`, `Retry`, and `Mastered`
- Updated lesson flow screens for Reading, Listening, Writing, Speaking, and Assessment

### Backend changes

- Added `.env` validation for OpenAI-backed generation
- Added startup checks for LLM configuration
- Switched the backend from a simple lesson prototype to a level-aware chapter model
- Added placement logic so the learner can pick a level after login
- Added progression state for level, chapter, and chapter outcomes
- Added real lesson generation for the current chapter using the LLM
- Added progress, profile, and flashcard endpoints for the frontend
- Added LLM-backed assessment evaluation with fallback behavior
- Added local development CORS handling for Flutter web

### Integration and demo hardening

- Connected Flutter to the FastAPI backend through a real API client
- Verified local login and backend app-data flows
- Verified live OpenAI lesson generation with a valid API key
- Fixed multiple live issues found during browser testing, including fetch and stale-progress bugs
- Updated seeded progress so chapter 5 starts pending while earlier chapters remain completed

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
- OpenAI

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

- Lessons are generated through OpenAI via LangChain
- Generation is conditioned on:
  - selected level
  - chapter number
  - grammar focus
  - vocabulary focus
  - target language

### Progress and evaluation

- Chapters 1-4 are seeded for the demo
- Chapter 5 is generated dynamically
- Assessment results update lesson and chapter outcomes
- The backend returns the learner status as promoted, retry, or mastered

## Key Frontend Capabilities

- Login screen for the demo account
- Level-selection screen after login
- Loading step that fetches app state from the backend
- Dashboard with lesson feed, progress, profile, and flashcards
- Lesson flow covering Reading, Listening, Writing, Speaking, and Assessment
- Result dialogs after the final lesson is completed

## API Summary

Main routes currently used by the demo:

- `POST /auth/login`
- `POST /app/placement`
- `GET /lessons?user_id=...`
- `GET /lessons/{lesson_id}/reading`
- `GET /lessons/{lesson_id}/listening`
- `GET /lessons/{lesson_id}/writing`
- `GET /lessons/{lesson_id}/speaking`
- `GET /lessons/{lesson_id}/assessment`
- `POST /lessons/{lesson_id}/submit-assessment`
- `GET /app/progress?user_id=...`
- `GET /app/profile?user_id=...`
- `GET /app/flashcards?user_id=...`

Swagger docs:

- `http://127.0.0.1:8000/docs`

## Environment Setup

Create a `.env` file in the project root with:

```env
LLM_PROVIDER=openai
OPENAI_API_KEY=your_real_openai_api_key
OPENAI_MODEL=gpt-4.1-mini
```

The backend validates this configuration on startup and rejects missing or placeholder API keys.

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
6. Submit the assessments.
7. Review the resulting progress, profile, and chapter outcome.

## Current Limitations

- Data is still in-memory for the hackathon demo
- Restarting the backend resets the active demo state
- The demo currently focuses on German only
- The progression model is intentionally simplified for presentation
- This project is currently intended for local demo use, not public deployment

## Why This Project Matters

LingoLearn is not trying to be a full Duolingo clone. The pitch is narrower and more specific:

- adaptive entry point instead of a one-size-fits-all beginner start
- fresh lesson generation based on learner level
- progression that reacts to learner performance
- a smoother, more personalized first experience

For the hackathon, this repo demonstrates that idea end-to-end with a working Flutter UI, a FastAPI backend, and live LLM-generated German lessons.
