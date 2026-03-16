from backend.app.db.users import UsersRepository
from backend.app.schemas.auth import LoginResponse


class InvalidCredentialsError(Exception):
    pass

class AuthService:
    def __init__(self, repo: UsersRepository):
        self.repo = repo

    def login(self, email: str, password: str):
        user = self.repo.get_by_email(email)

        if not user or user["password"] != password:
            raise InvalidCredentialsError("Invalid Credentials")

        return LoginResponse(
            authenticated=True,
            user_id=user["user_id"],
            name=user["name"],
            email=user["email"],
            native_language=user.get("native_language", "English"),
            target_language=user.get("target_language", "German"),
            demo_mode=True,
            message="Login Successful",
        )
