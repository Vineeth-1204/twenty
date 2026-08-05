from datetime import datetime
from pydantic import BaseModel, ConfigDict
from app.schemas.user import UserAuthorResponse

class CommentCreate(BaseModel):
    content: str

class CommentResponse(BaseModel):
    id: int
    content: str
    created_at: datetime
    author: UserAuthorResponse

    model_config = ConfigDict(from_attributes=True)
