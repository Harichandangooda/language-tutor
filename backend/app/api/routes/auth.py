from fastapi import APIRouter, Depends, HTTPException, status

from backend.app.dependencies import get_auth_service
from backend.app.schemas.auth import LoginRequest, LoginResponse
from backend.app.services.auth_service import AuthService, InvalidCredentialsError

router = APIRouter()


@router.post(
    "/auth/login",
    response_model=LoginResponse,
    status_code=status.HTTP_200_OK,
)
def login(
    request: LoginRequest,
    service: AuthService = Depends(get_auth_service),
) -> LoginResponse:
    try:
        return service.login(request.email, request.password)
    except InvalidCredentialsError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(exc)
        ) from exc