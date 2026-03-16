from __future__ import annotations

from copy import deepcopy
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

from backend.app.db.base import InMemoryRepository


class LessonsRepository(InMemoryRepository[Dict[str, Any]]):
    def create_lesson(
        self,
        lesson_id: str,
        user_id: str,
        lesson_package: Dict[str, Any],
        slot: int | None = None,
        slug: str | None = None,
        day_label: str | None = None,
        level: int | None = None,
        chapter: int | None = None,
    ) -> Dict[str, Any]:
        record = {
            'lesson_id': lesson_id,
            'user_id': user_id,
            'status': 'ready',
            'slot': slot,
            'slug': slug,
            'day_label': day_label,
            'level': level,
            'chapter': chapter,
            'lesson_package': deepcopy(lesson_package),
            'created_at': datetime.now(timezone.utc).isoformat(),
        }
        return self.save(lesson_id, record)

    def list_by_user(self, user_id: str) -> List[Dict[str, Any]]:
        lessons = [lesson for lesson in self.list_all() if lesson['user_id'] == user_id]
        return sorted(
            lessons,
            key=lambda item: (
                item.get('slot') is None,
                item.get('slot', 999),
                item['created_at'],
            ),
        )

    def get_by_user_and_slot(self, user_id: str, slot: int) -> Optional[Dict[str, Any]]:
        for lesson in self.list_by_user(user_id):
            if lesson.get('slot') == slot:
                return lesson
        return None

    def delete_by_user(self, user_id: str) -> int:
        deleted = 0
        for lesson in self.list_by_user(user_id):
            if self.delete(lesson["lesson_id"]):
                deleted += 1
        return deleted

    def get_section(self, lesson_id: str, section_name: str) -> Optional[Dict[str, Any]]:
        lesson = self.get(lesson_id)
        if not lesson:
            return None
        return lesson['lesson_package'].get(section_name)

    def get_card(self, lesson_id: str) -> Optional[Dict[str, Any]]:
        return self.get_section(lesson_id, 'card')

    def mark_completed(self, lesson_id: str) -> Optional[Dict[str, Any]]:
        lesson = self.get(lesson_id)
        if not lesson:
            return None
        lesson['status'] = 'completed'
        lesson['completed_at'] = datetime.now(timezone.utc).isoformat()
        return self.save(lesson_id, lesson)
