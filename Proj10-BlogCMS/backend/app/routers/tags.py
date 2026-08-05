import re
from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.tag import Tag
from app.schemas.tag import TagCreate, TagResponse
from app.auth.dependencies import get_current_active_user
from app.models.user import User

router = APIRouter(prefix="/tags", tags=["Tags"])

def slugify(text: str) -> str:
    text = text.lower().strip()
    text = re.sub(r'[^\w\s-]', '', text)
    text = re.sub(r'[\s_-]+', '-', text)
    return text.strip('-')

@router.get("", response_model=List[TagResponse])
def get_tags(db: Session = Depends(get_db)):
    """Fetch all tags."""
    return db.query(Tag).all()

@router.post("", response_model=TagResponse, status_code=status.HTTP_201_CREATED)
def create_tag(
    tag_in: TagCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Create a new tag (authenticated users)."""
    slug = slugify(tag_in.name)
    existing = db.query(Tag).filter(Tag.slug == slug).first()
    if existing:
        return existing  # Return existing tag if already present

    tag = Tag(name=tag_in.name, slug=slug)
    db.add(tag)
    db.commit()
    db.refresh(tag)
    return tag
