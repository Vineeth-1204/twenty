from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, ConfigDict
from app.models.post import PostStatus
from app.schemas.user import UserAuthorResponse
from app.schemas.category import CategoryResponse
from app.schemas.tag import TagResponse

class PostBase(BaseModel):
    title: str
    summary: Optional[str] = None
    content: str
    cover_image: Optional[str] = None
    status: PostStatus = PostStatus.DRAFT

class PostCreate(PostBase):
    category_id: Optional[int] = None
    tag_ids: Optional[List[int]] = []

class PostUpdate(BaseModel):
    title: Optional[str] = None
    summary: Optional[str] = None
    content: Optional[str] = None
    cover_image: Optional[str] = None
    status: Optional[PostStatus] = None
    category_id: Optional[int] = None
    tag_ids: Optional[List[int]] = None

class PostResponse(PostBase):
    id: int
    slug: str
    views_count: int
    created_at: datetime
    updated_at: datetime
    author: UserAuthorResponse
    category: Optional[CategoryResponse] = None
    tags: List[TagResponse] = []

    model_config = ConfigDict(from_attributes=True)

class PostListResponse(BaseModel):
    items: List[PostResponse]
    total: int
    page: int
    size: int
    pages: int
