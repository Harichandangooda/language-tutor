from __future__ import annotations

from copy import deepcopy
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

from backend.app.db.base import InMemoryRepository


class AttemptsRepository(InMemoryRepository[Dict[str, Any]]):
    def create_attempt(
        self,
        attempt_id: str,
        lesson_id: str,
        user_id: str,
        submission: Dict[str, Any],
        metrics: Dict[str, Any],
        evaluation: Dict[str, Any],
    ) -> Dict[str, Any]:
        record = {
            "attempt_id": attempt_id,
            "lesson_id": lesson_id,
            "user_id": user_id,
            "submission": deepcopy(submission),
            "metrics": deepcopy(metrics),
            "evaluation": deepcopy(evaluation),
            "submitted_at": datetime.now(timezone.utc).isoformat(),
        }
        return self.save(attempt_id, record)

    def list_by_user(self, user_id: str) -> List[Dict[str, Any]]:
        attempts = [item for item in self.list_all() if item["user_id"] == user_id]
        return sorted(attempts, key=lambda item: item["submitted_at"], reverse=True)

    def list_by_lesson(self, lesson_id: str) -> List[Dict[str, Any]]:
        attempts = [item for item in self.list_all() if item["lesson_id"] == lesson_id]
        return sorted(attempts, key=lambda item: item["submitted_at"], reverse=True)

    def get_latest_by_lesson(self, lesson_id: str) -> Optional[Dict[str, Any]]:
        attempts = self.list_by_lesson(lesson_id)
        return attempts[0] if attempts else None