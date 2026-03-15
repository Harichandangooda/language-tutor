from __future__ import annotations

from copy import deepcopy
from datetime import datetime, timezone
from typing import Any, Dict, List

from backend.app.db.base import InMemoryRepository


class FlashcardsRepository(InMemoryRepository[Dict[str, Any]]):
    def add_cards(self, user_id: str, cards: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        saved_cards: List[Dict[str, Any]] = []

        for idx, card in enumerate(cards, start=1):
            flashcard_id = f"{user_id}_flashcard_{len(self._data) + idx}"
            record = {
                "flashcard_id": flashcard_id,
                "user_id": user_id,
                "word": card["word"],
                "meaning": card.get("meaning", ""),
                "example": card.get("example", ""),
                "status": card.get("status", "learning"),
                "created_at": datetime.now(timezone.utc).isoformat(),
            }
            saved_cards.append(self.save(flashcard_id, deepcopy(record)))

        return saved_cards

    def list_by_user(self, user_id: str) -> List[Dict[str, Any]]:
        cards = [item for item in self.list_all() if item["user_id"] == user_id]
        return sorted(cards, key=lambda item: item["created_at"], reverse=True)