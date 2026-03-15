from fastapi import FastAPI

from backend.app.api.routes.auth import router as auth_router
from backend.app.api.routes.lessons import router as lessons_router
from backend.app.api.routes.assessment import router as assessment_router
from dotenv import load_dotenv

load_dotenv(override=True)


app = FastAPI()
app.include_router(auth_router)
app.include_router(lessons_router)
app.include_router(assessment_router)