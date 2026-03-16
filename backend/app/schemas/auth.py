from pydantic import BaseModel


class LoginRequest(BaseModel):
    email: str
    password: str


class LoginResponse(BaseModel):
    authenticated: bool
    user_id: str | None = None
    name: str | None = None
    email: str | None = None
    native_language: str | None = None
    target_language: str | None = None
    demo_mode: bool = True
    message: str | None = None
