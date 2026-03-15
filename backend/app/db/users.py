from __future__ import annotations

from dataclasses import dataclass, asdict
from typing import Dict, Optional

from backend.app.db.base import InMemoryRepository


@dataclass
class UserRecord:
    user_id: str
    email: str
    password: str
    name: str
    native_language: str = "English"
    target_language: str = "German"

    def to_dict(self) -> Dict[str, str]:
        return asdict(self)


class UsersRepository(InMemoryRepository[Dict[str, str]]):
    def seed_demo_users(self) -> None:
        demo_users = [
            UserRecord(
                user_id="u_001",
                email="hari@example.com",
                password="demo123",
                name="Hari",
            ),
            UserRecord(
                user_id="u_002",
                email="student@example.com",
                password="demo123",
                name="Student",
            ),
        ]
        for user in demo_users:
            self.save(user.user_id, user.to_dict())

    def get_by_email(self, email: str) -> Optional[Dict[str, str]]:
        for user in self.list_all():
            if user["email"].lower() == email.lower():
                return user
        return None

    def create_user(self, record: UserRecord) -> Dict[str, str]:
        if self.get_by_email(record.email):
            raise ValueError(f"User with email {record.email} already exists.")
        return self.save(record.user_id, record.to_dict())
