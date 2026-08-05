import re
from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.database.session import get_db
from app.models.category import Category
from app.models.post import Post, PostStatus
from app.schemas.category import CategoryCreate, CategoryResponse
from app.auth.dependencies import get_current_active_user
from app.models.user import User

router = APIRouter(prefix="/categories", tags=["Categories"])

def slugify(text: str) -> str:
    """Converts a string to a URL-friendly slug."""
    text = text.lower().strip()
    text = re.sub(r'[^\w\s-]', '', text)
    text = re.sub(r'[\s_-]+', '-', text)
    return text.strip('-')

@router.get("", response_model=List[CategoryResponse])
def get_categories(db: Session = Depends(get_db)):
    """Fetch all categories along with post counts."""
    categories = db.query(Category).all()
    result = []
    for cat in categories:
        published_count = db.query(func.count(Post.id)).filter(
            Post.category_id == cat.id,
            Post.status == PostStatus.PUBLISHED
        ).scalar()
        
        cat_dict = {
            "id": cat.id,
            "name": cat.name,
            "slug": cat.slug,
            "description": cat.description,
            "posts_count": published_count or 0
        }
        result.append(cat_dict)
    return result

@router.post("", response_model=CategoryResponse, status_code=status.HTTP_201_CREATED)
def create_category(
    cat_in: CategoryCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Create a new category (authenticated users)."""
    slug = slugify(cat_in.name)
    existing = db.query(Category).filter(Category.slug == slug).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Category with this name or slug already exists."
        )

    category = Category(
        name=cat_in.name,
        slug=slug,
        description=cat_in.description
    )
    db.add(category)
    db.commit()
    db.refresh(category)
    category.posts_count = 0
    return category

@router.delete("/{category_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_category(
    category_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Delete a category."""
    category = db.query(Category).filter(Category.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    
    db.delete(category)
    db.commit()
    return None
