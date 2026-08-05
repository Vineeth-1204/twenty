import re
import math
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import or_, desc

from app.database.session import get_db
from app.models.post import Post, PostStatus
from app.models.category import Category
from app.models.tag import Tag
from app.models.user import User
from app.schemas.post import PostCreate, PostUpdate, PostResponse, PostListResponse
from app.auth.dependencies import get_current_active_user, get_current_user

router = APIRouter(prefix="/posts", tags=["Posts"])

def generate_unique_slug(title: str, db: Session, post_id: Optional[int] = None) -> str:
    """Generate a clean, unique slug from a title."""
    base_slug = title.lower().strip()
    base_slug = re.sub(r'[^\w\s-]', '', base_slug)
    base_slug = re.sub(r'[\s_-]+', '-', base_slug).strip('-')
    if not base_slug:
        base_slug = "post"

    slug = base_slug
    counter = 1
    query = db.query(Post).filter(Post.slug == slug)
    if post_id:
        query = query.filter(Post.id != post_id)
        
    while query.first() is not None:
        slug = f"{base_slug}-{counter}"
        counter += 1
        query = db.query(Post).filter(Post.slug == slug)
        if post_id:
            query = query.filter(Post.id != post_id)
            
    return slug

@router.get("", response_model=PostListResponse)
def get_posts(
    search: Optional[str] = Query(None, description="Search term in title, summary, or content"),
    category: Optional[str] = Query(None, description="Category slug"),
    tag: Optional[str] = Query(None, description="Tag slug"),
    status: Optional[str] = Query(None, description="Filter by status: published/draft"),
    author_id: Optional[int] = Query(None, description="Filter by author user ID"),
    page: int = Query(1, ge=1, description="Page number"),
    size: int = Query(9, ge=1, le=50, description="Items per page"),
    db: Session = Depends(get_db)
):
    """
    Get paginated blog posts with keyword search, category, tag, author, and status filters.
    """
    query = db.query(Post).options(
        joinedload(Post.author),
        joinedload(Post.category),
        joinedload(Post.tags)
    )

    # Filter by Status (Default to published if unspecified)
    if status:
        if status.lower() == "published":
            query = query.filter(Post.status == PostStatus.PUBLISHED)
        elif status.lower() == "draft":
            query = query.filter(Post.status == PostStatus.DRAFT)
    else:
        # Default behavior for public feed: published posts only
        query = query.filter(Post.status == PostStatus.PUBLISHED)

    # Filter by Category slug
    if category:
        query = query.join(Post.category).filter(Category.slug == category)

    # Filter by Tag slug
    if tag:
        query = query.join(Post.tags).filter(Tag.slug == tag)

    # Filter by Author ID
    if author_id:
        query = query.filter(Post.author_id == author_id)

    # Search filter across title, summary, content
    if search:
        search_fmt = f"%{search}%"
        query = query.filter(
            or_(
                Post.title.ilike(search_fmt),
                Post.summary.ilike(search_fmt),
                Post.content.ilike(search_fmt)
            )
        )

    # Total count calculation
    total = query.distinct().count()
    pages = math.ceil(total / size) if total > 0 else 1

    # Sorting & Pagination
    posts = (
        query.distinct()
        .order_by(desc(Post.created_at))
        .offset((page - 1) * size)
        .limit(size)
        .all()
    )

    return PostListResponse(
        items=posts,
        total=total,
        page=page,
        size=size,
        pages=pages
    )

@router.get("/{slug_or_id}", response_model=PostResponse)
def get_post_by_slug_or_id(
    slug_or_id: str,
    db: Session = Depends(get_db)
):
    """
    Retrieve single post details by slug or numeric ID.
    Increments view counter on retrieval.
    """
    query = db.query(Post).options(
        joinedload(Post.author),
        joinedload(Post.category),
        joinedload(Post.tags)
    )

    if slug_or_id.isdigit():
        post = query.filter(Post.id == int(slug_or_id)).first()
    else:
        post = query.filter(Post.slug == slug_or_id).first()

    if not post:
        raise HTTPException(status_code=404, detail="Post not found")

    # Increment view counter
    post.views_count = (post.views_count or 0) + 1
    db.commit()
    db.refresh(post)

    return post

@router.post("", response_model=PostResponse, status_code=status.HTTP_201_CREATED)
def create_post(
    post_in: PostCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Create a new post (authenticated users)."""
    slug = generate_unique_slug(post_in.title, db)

    post = Post(
        title=post_in.title,
        slug=slug,
        summary=post_in.summary,
        content=post_in.content,
        cover_image=post_in.cover_image,
        status=post_in.status,
        author_id=current_user.id,
        category_id=post_in.category_id
    )

    # Attach tags
    if post_in.tag_ids:
        tags = db.query(Tag).filter(Tag.id.in_(post_in.tag_ids)).all()
        post.tags = tags

    db.add(post)
    db.commit()
    db.refresh(post)

    # Return with relations reloaded
    return db.query(Post).options(
        joinedload(Post.author),
        joinedload(Post.category),
        joinedload(Post.tags)
    ).filter(Post.id == post.id).first()

@router.put("/{post_id}", response_model=PostResponse)
def update_post(
    post_id: int,
    post_in: PostUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Update an existing post (author or admin only)."""
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")

    if post.author_id != current_user.id and not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Not authorized to edit this post")

    # Update basic fields if provided
    if post_in.title is not None and post_in.title != post.title:
        post.title = post_in.title
        post.slug = generate_unique_slug(post_in.title, db, post_id=post.id)
    if post_in.summary is not None:
        post.summary = post_in.summary
    if post_in.content is not None:
        post.content = post_in.content
    if post_in.cover_image is not None:
        post.cover_image = post_in.cover_image
    if post_in.status is not None:
        post.status = post_in.status
    if post_in.category_id is not None:
        post.category_id = post_in.category_id

    # Update tags if provided
    if post_in.tag_ids is not None:
        tags = db.query(Tag).filter(Tag.id.in_(post_in.tag_ids)).all()
        post.tags = tags

    db.commit()
    db.refresh(post)

    return db.query(Post).options(
        joinedload(Post.author),
        joinedload(Post.category),
        joinedload(Post.tags)
    ).filter(Post.id == post.id).first()

@router.delete("/{post_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_post(
    post_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Delete a post (author or admin only)."""
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")

    if post.author_id != current_user.id and not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Not authorized to delete this post")

    db.delete(post)
    db.commit()
    return None
