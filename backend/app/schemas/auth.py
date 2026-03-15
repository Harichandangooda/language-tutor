from pydantic import BaseModel

class LoginRequest(BaseModel):
    email: str
    password: str

class LoginResponse(BaseModel):
    authenticated: bool
    user_id: str | None = None
    name: str | None = None
    message: str | None = None