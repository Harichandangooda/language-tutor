from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from backend.app.api.routes.auth import router as auth_router
from backend.app.api.routes.lessons import router as lessons_router
from backend.app.api.routes.assessment import router as assessment_router
from backend.app.api.routes.app_data import router as app_data_router
from backend.app.core.settings import SettingsError, validate_settings
from dotenv import load_dotenv

load_dotenv(override=True)


app = FastAPI(
    title="Language Tutor API",
    version="0.1.0",
    description="Hackathon demo backend for a German language tutoring flow.",
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost",
        "http://127.0.0.1",
    ],
    allow_origin_regex=r"^https?://(localhost|127\.0\.0\.1)(:\d+)?$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(auth_router)
app.include_router(lessons_router)
app.include_router(assessment_router)
app.include_router(app_data_router)


@app.on_event("startup")
def validate_runtime_configuration() -> None:
    try:
        validate_settings()
    except SettingsError as exc:
        raise RuntimeError(str(exc)) from exc
