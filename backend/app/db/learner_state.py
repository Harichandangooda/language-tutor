from __future__ import annotations

from copy import deepcopy
from datetime import datetime, timezone
from typing import Any, Dict, Optional

from backend.app.db.base import InMemoryRepository


def default_learner_state(user_id: str, native_language: str = 'English', target_language: str = 'German') -> Dict[str, Any]:
    return {
        'user_id': user_id,
        'language_profile': {
            'native_language': native_language,
            'target_language': target_language,
            'current_level': 'A1',
        },
        'skill_levels': {
            'reading': 0.5,
            'listening': 0.5,
            'writing': 0.5,
            'speaking': 0.5,
        },
        'vocabulary': {
            'mastered_words': [],
            'learning_words': [],
            'review_words': [],
        },
        'grammar': {
            'learned_topics': [],
            'weak_topics': [],
        },
        'recent_performance': {
            'last_lesson_score': 0.0,
            'reading_score': 0.0,
            'listening_score': 0.0,
            'writing_score': 0.0,
            'speaking_score': 0.0,
        },
        'lesson_history': {
            'lessons_completed': 0,
            'last_lesson_id': None,
            'last_lesson_date': None,
        },
        'next_lesson_focus': {
            'topic': 'introductory greetings',
            'grammar': 'basic present tense',
            'difficulty': 'A1',
        },
        'updated_at': datetime.now(timezone.utc).isoformat(),
    }


class LearnerStateRepository(InMemoryRepository[Dict[str, Any]]):
    def get_or_create(
        self,
        user_id: str,
        native_language: str = 'English',
        target_language: str = 'German',
    ) -> Dict[str, Any]:
        state = self.get(user_id)
        if state is not None:
            return state
        return self.save(user_id, default_learner_state(user_id, native_language, target_language))

    def patch(self, user_id: str, update: Dict[str, Any]) -> Dict[str, Any]:
        current = self.get_or_create(user_id)
        merged = self._deep_merge(current, update)
        merged['updated_at'] = datetime.now(timezone.utc).isoformat()
        return self.save(user_id, merged)

    def _deep_merge(self, current: Dict[str, Any], update: Dict[str, Any]) -> Dict[str, Any]:
        result = deepcopy(current)
        for key, value in update.items():
            if isinstance(value, dict) and isinstance(result.get(key), dict):
                result[key] = self._deep_merge(result[key], value)
            else:
                result[key] = deepcopy(value)
        return result
