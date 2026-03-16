from fastapi import APIRouter, Depends, HTTPException, status

from backend.app.schemas.assessment import AssessmentResult, AssessmentSubmission
from backend.app.dependencies import get_assessment_service
from backend.app.services.assessment_service import InvalidSubmissionError, LessonNotFoundError

router = APIRouter(prefix="/lessons", tags=["assessment"])


@router.post("/{lesson_id}/submit-assessment", response_model=AssessmentResult)
def submit_assessment(
    lesson_id: str,
    request: AssessmentSubmission,
    service=Depends(get_assessment_service),
):
    try:
        return service.submit_assessment(
            lesson_id=lesson_id,
            submission=request,
        )
    except LessonNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        ) from exc
    except InvalidSubmissionError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        ) from exc
