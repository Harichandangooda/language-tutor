from __future__ import annotations

from pprint import pprint

from backend.app.db import (
    AttemptsRepository,
    FlashcardsRepository,
    LearnerStateRepository,
    LessonsRepository,
    UsersRepository,
)


def run_demo() -> None:
    users_repo = UsersRepository()
    users_repo.seed_demo_users()

    learner_state_repo = LearnerStateRepository()
    lessons_repo = LessonsRepository()
    attempts_repo = AttemptsRepository()
    flashcards_repo = FlashcardsRepository()

    user = users_repo.authenticate('hari@example.com', 'demo123')
    pprint({'authenticated_user': user})

    state = learner_state_repo.get_or_create(user['user_id'])
    pprint({'initial_state': state})

    lesson_package = {
        'card': {
            'lesson_id': 'lesson_001',
            'title': 'Daily Routine Basics',
            'objective': 'Learn simple verbs around daily life',
            'image_url': 'https://example.com/daily-routine.png',
        },
        'reading': {'passage': 'Ich stehe um sieben Uhr auf.', 'questions': []},
        'listening': {'audio_script': 'Ich frühstücke um acht Uhr.', 'questions': []},
        'writing': {'prompt': 'Write 2 sentences about your routine.', 'expected_keywords': ['ich', 'gehe']},
        'speaking': {'prompt': 'Say your morning routine aloud.', 'expected_phrases': ['ich stehe auf']},
        'assessment': {'questions': [{'question_id': 'a1', 'prompt': 'Translate: I go to school.'}]},
    }
    lessons_repo.create_lesson('lesson_001', user['user_id'], lesson_package)
    pprint({'lesson_card': lessons_repo.get_card('lesson_001')})

    attempt = attempts_repo.save_attempt(
        'attempt_001',
        {
            'user_id': user['user_id'],
            'lesson_id': 'lesson_001',
            'reading_score': 0.8,
            'listening_score': 0.7,
            'writing_score': 0.6,
            'speaking_score': 0.5,
        },
    )
    pprint({'attempt': attempt})

    learner_state_repo.patch(
        user['user_id'],
        {
            'lesson_history': {
                'lessons_completed': 1,
                'last_lesson_id': 'lesson_001',
                'last_lesson_date': '2026-03-13',
            },
            'vocabulary': {
                'learning_words': ['gehen', 'frühstücken'],
                'review_words': ['gehen'],
            },
        },
    )
    pprint({'updated_state': learner_state_repo.get(user['user_id'])})

    flashcards = flashcards_repo.add_cards(
        user['user_id'],
        [
            {'word': 'gehen', 'meaning': 'to go', 'example': 'Ich gehe zur Schule.'},
            {'word': 'frühstücken', 'meaning': 'to have breakfast', 'example': 'Ich frühstücke um acht Uhr.'},
        ],
    )
    pprint({'flashcards_added': flashcards})
    pprint({'all_flashcards': flashcards_repo.list_by_user(user['user_id'])})


if __name__ == '__main__':
    run_demo()
