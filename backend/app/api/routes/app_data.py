from fastapi import APIRouter, Depends, HTTPException, Query, status

from backend.app.dependencies import get_app_data_service
from backend.app.schemas.app_views import (
    FlashcardListResponse,
    LevelSelectionRequest,
    LevelSelectionResponse,
    ProfileSummaryResponse,
    ProgressSummaryResponse,
)
from backend.app.services.app_data_service import AppDataRequestError, AppDataService

router = APIRouter(prefix="/app", tags=["app"])


@router.post("/placement", response_model=LevelSelectionResponse)
def set_level(
    request: LevelSelectionRequest,
    service: AppDataService = Depends(get_app_data_service),
):
    try:
        return service.set_level(request.user_id, request.level)
    except AppDataRequestError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        ) from exc


@router.get("/progress", response_model=ProgressSummaryResponse)
def get_progress(
    user_id: str = Query(...),
    service: AppDataService = Depends(get_app_data_service),
):
    try:
        return service.get_progress_summary(user_id)
    except AppDataRequestError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        ) from exc


@router.get("/profile", response_model=ProfileSummaryResponse)
def get_profile(
    user_id: str = Query(...),
    service: AppDataService = Depends(get_app_data_service),
):
    try:
        return service.get_profile_summary(user_id)
    except AppDataRequestError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        ) from exc


@router.get("/flashcards", response_model=FlashcardListResponse)
def get_flashcards(
    user_id: str = Query(...),
    service: AppDataService = Depends(get_app_data_service),
):
    try:
        return service.get_flashcards(user_id)
    except AppDataRequestError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        ) from exc
