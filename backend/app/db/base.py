from __future__ import annotations

from copy import deepcopy
from threading import Lock
from typing import Dict, Generic, List, Optional, TypeVar

T = TypeVar('T')


class InMemoryRepository(Generic[T]):
    """Thread-safe in-memory repository for hackathon MVPs."""

    def __init__(self) -> None:
        self._data: Dict[str, T] = {}
        self._lock = Lock()

    def get(self, key: str) -> Optional[T]:
        with self._lock:
            value = self._data.get(key)
            return deepcopy(value) if value is not None else None

    def save(self, key: str, value: T) -> T:
        with self._lock:
            self._data[key] = deepcopy(value)
            return deepcopy(value)

    def delete(self, key: str) -> bool:
        with self._lock:
            if key in self._data:
                del self._data[key]
                return True
            return False

    def list_all(self) -> List[T]:
        with self._lock:
            return deepcopy(list(self._data.values()))

    def exists(self, key: str) -> bool:
        with self._lock:
            return key in self._data
