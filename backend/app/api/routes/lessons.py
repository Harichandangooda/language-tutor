from fastapi import APIRouter, Depends, HTTPException, status

from backend.app.schemas.lesson import LessonStartRequest
from backend.app.dependencies import get_lesson_service
from backend.app.services.lesson_service import (
    LessonService,
    LessonNotFoundError,
    InvalidLessonRequestError,
)

router = APIRouter(prefix="/lessons", tags=["lessons"])


@router.post("/start")
def start_lesson(
    request: LessonStartRequest,
    service: LessonService = Depends(get_lesson_service),
):
    try:
        return service.start_lesson(request.user_id)
    except InvalidLessonRequestError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        ) from exc


@router.get("/{lesson_id}/card")
def get_card(
    lesson_id: str,
    service: LessonService = Depends(get_lesson_service),
):
    try:
        return service.get_card(lesson_id)
    except LessonNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        ) from exc


@router.get("/{lesson_id}/reading")
def get_reading(
    lesson_id: str,
    service: LessonService = Depends(get_lesson_service),
):
    try:
        return service.get_reading(lesson_id)
    except LessonNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        ) from exc


@router.get("/{lesson_id}/listening")
def get_listening(
    lesson_id: str,
    service: LessonService = Depends(get_lesson_service),
):
    try:
        return service.get_listening(lesson_id)
    except LessonNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        ) from exc


@router.get("/{lesson_id}/writing")
def get_writing(
    lesson_id: str,
    service: LessonService = Depends(get_lesson_service),
):
    try:
        return service.get_writing(lesson_id)
    except LessonNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        ) from exc


@router.get("/{lesson_id}/speaking")
def get_speaking(
    lesson_id: str,
    service: LessonService = Depends(get_lesson_service),
):
    try:
        return service.get_speaking(lesson_id)
    except LessonNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        ) from exc


@router.get("/{lesson_id}/assessment")
def get_assessment(
    lesson_id: str,
    service: LessonService = Depends(get_lesson_service),
):
    try:
        return service.get_assessment(lesson_id)
    except LessonNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        ) from exc