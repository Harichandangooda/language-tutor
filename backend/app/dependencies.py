from fastapi import Depends

from backend.app.db.users import UsersRepository
from backend.app.db.learner_state import LearnerStateRepository
from backend.app.db.lessons import LessonsRepository
from backend.app.db.attempts import AttemptsRepository
from backend.app.db.flashcards import FlashcardsRepository

from backend.app.services.auth_service import AuthService
from backend.app.services.lesson_service import LessonService
from backend.app.services.assessment_service import AssessmentService


_users_repo = UsersRepository()
_users_repo.seed_demo_users()

_learner_state_repo = LearnerStateRepository()
_lessons_repo = LessonsRepository()
_attempts_repo = AttemptsRepository()
_flashcards_repo = FlashcardsRepository()


# Repos
def get_users_repository() -> UsersRepository:
    return _users_repo


def get_learner_state_repository() -> LearnerStateRepository:
    return _learner_state_repo


def get_lessons_repository() -> LessonsRepository:
    return _lessons_repo


def get_attempts_repository() -> AttemptsRepository:
    return _attempts_repo


def get_flashcards_repository() -> FlashcardsRepository:
    return _flashcards_repo


# Services
def get_auth_service(
    repo: UsersRepository = Depends(get_users_repository),
) -> AuthService:
    return AuthService(repo)


def get_lesson_service(
    learner_state_repo: LearnerStateRepository = Depends(get_learner_state_repository),
    lessons_repo: LessonsRepository = Depends(get_lessons_repository),
) -> LessonService:
    return LessonService(
        learner_state_repo=learner_state_repo,
        lessons_repo=lessons_repo,
    )


def get_assessment_service(
    lessons_repo: LessonsRepository = Depends(get_lessons_repository),
    learner_state_repo: LearnerStateRepository = Depends(get_learner_state_repository),
    attempts_repo: AttemptsRepository = Depends(get_attempts_repository),
    flashcards_repo: FlashcardsRepository = Depends(get_flashcards_repository),
) -> AssessmentService:
    return AssessmentService(
        lessons_repo=lessons_repo,
        learner_state_repo=learner_state_repo,
        attempts_repo=attempts_repo,
        flashcards_repo=flashcards_repo,
    )