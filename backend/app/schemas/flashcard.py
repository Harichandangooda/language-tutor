from pydantic import BaseModel

class Flashcard(BaseModel):
    word: str
    meaning: str
    example: str
    status: str