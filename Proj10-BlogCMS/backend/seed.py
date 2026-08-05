import os
import sys

# Ensure backend path is in sys.path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database.session import SessionLocal, engine, Base
from app.models.user import User
from app.models.category import Category
from app.models.tag import Tag
from app.models.post import Post, PostStatus
from app.models.comment import Comment
from app.auth.security import get_password_hash

def seed_database():
    print("[+] Initializing Database tables...")
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    try:
        # 1. Create Users
        print("[+] Creating Users...")
        admin = db.query(User).filter(User.username == "admin").first()
        if not admin:
            admin = User(
                username="admin",
                email="admin@blogcms.com",
                password_hash=get_password_hash("admin123"),
                full_name="Alex Rivera",
                bio="Senior Tech Lead & Open Source Enthusiast. Writing about FastAPI, React, and modern web systems.",
                avatar_url="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80",
                is_admin=True,
                is_active=True
            )
            db.add(admin)

        author = db.query(User).filter(User.username == "johndoe").first()
        if not author:
            author = User(
                username="johndoe",
                email="john@example.com",
                password_hash=get_password_hash("password123"),
                full_name="John Doe",
                bio="Full-Stack Developer who loves building slick user interfaces with React and Tailwind CSS.",
                avatar_url="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80",
                is_admin=False,
                is_active=True
            )
            db.add(author)

        db.commit()
        db.refresh(admin)
        db.refresh(author)

        # 2. Create Categories
        print("[+] Creating Categories...")
        categories_data = [
            {"name": "Web Development", "slug": "web-development", "description": "Latest trends, frameworks, and best practices in frontend and backend web development."},
            {"name": "Artificial Intelligence", "slug": "artificial-intelligence", "description": "Explorations in Machine Learning, Large Language Models, and modern AI tools."},
            {"name": "UI/UX Design", "slug": "ui-ux-design", "description": "Designing intuitive interfaces, glassmorphism, accessibility, and modern aesthetics."},
            {"name": "DevOps & Cloud", "slug": "devops-cloud", "description": "Docker, Kubernetes, CI/CD pipelines, and cloud deployment strategies."}
        ]

        cat_map = {}
        for cdata in categories_data:
            cat = db.query(Category).filter(Category.slug == cdata["slug"]).first()
            if not cat:
                cat = Category(**cdata)
                db.add(cat)
                db.commit()
                db.refresh(cat)
            cat_map[cdata["slug"]] = cat

        # 3. Create Tags
        print("[+] Creating Tags...")
        tags_data = [
            {"name": "FastAPI", "slug": "fastapi"},
            {"name": "React", "slug": "react"},
            {"name": "Python", "slug": "python"},
            {"name": "TailwindCSS", "slug": "tailwindcss"},
            {"name": "JWT", "slug": "jwt"},
            {"name": "SQLAlchemy", "slug": "sqlalchemy"}
        ]

        tag_map = {}
        for tdata in tags_data:
            tag = db.query(Tag).filter(Tag.slug == tdata["slug"]).first()
            if not tag:
                tag = Tag(**tdata)
                db.add(tag)
                db.commit()
                db.refresh(tag)
            tag_map[tdata["slug"]] = tag

        # 4. Create Sample Posts
        print("[+] Creating Sample Blog Posts...")
        posts_data = [
            {
                "title": "Building High-Performance APIs with FastAPI and Python 3.12",
                "slug": "building-high-performance-apis-fastapi-python-312",
                "summary": "Discover why FastAPI has become the default choice for modern Python backends, leveraging async await, Pydantic data validation, and automatic Swagger docs.",
                "content": """# Building High-Performance APIs with FastAPI and Python 3.12

FastAPI is a modern, fast (high-performance), web framework for building APIs with Python 3.8+ based on standard Python type hints.

## Key Features

1. **Fast**: Very high performance, on par with **NodeJS** and **Go** (thanks to Starlette and Pydantic).
2. **Fast to code**: Increase speed to develop features by about 200% to 300%.
3. **Fewer bugs**: Reduce about 40% of human (developer) induced errors.
4. **Intuitive**: Great editor support. Auto-completion everywhere. Less time debugging.
5. **Standards-based**: Based on OpenAPI (previously known as Swagger) and JSON Schema.

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello World from FastAPI!"}
```

## Dependency Injection Engine

FastAPI provides an extremely powerful Dependency Injection system that simplifies database session management, authentication token validation, and parameter extraction.

```python
@app.get("/users/me")
def read_current_user(current_user: User = Depends(get_current_active_user)):
    return current_user
```

Stay tuned for part two where we explore full integration with SQLAlchemy ORM!""",
                "cover_image": "https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=1200&q=80",
                "status": PostStatus.PUBLISHED,
                "author_id": admin.id,
                "category_id": cat_map["web-development"].id,
                "tags": [tag_map["fastapi"], tag_map["python"], tag_map["jwt"]]
            },
            {
                "title": "Mastering React 18 & Vite: Modern Frontend Architecture",
                "slug": "mastering-react-18-vite-modern-frontend-architecture",
                "summary": "Learn how Vite's instant HMR paired with React 18 concurrent features provides a blazing fast developer experience and ultra-smooth user interface.",
                "content": """# Mastering React 18 & Vite: Modern Frontend Architecture

The web development ecosystem has evolved rapidly over the past few years. Traditional bundlers like Webpack are increasingly being replaced by **Vite**, powered by esbuild and native ES modules.

## Why Choose Vite for React?

* Instant Server Start: No waiting for bundling before dev server starts.
* Lightning Fast HMR: Hot Module Replacement that remains fast regardless of app size.
* Out-of-the-box Support: TypeScript, JSX, CSS modules work seamlessly without complex config files.

```jsx
import { useState } from 'react';

export function Counter() {
  const [count, setCount] = useState(0);
  return (
    <button onClick={() => setCount(c => c + 1)} className="btn-primary">
      Clicked {count} times
    </button>
  );
}
```

## State Management with React Context

For medium-sized applications like CMS platforms, React Context API provides clean global state management for Authentication tokens and Theme modes without external boilerplate libraries.

```jsx
const AuthContext = createContext(null);
```""",
                "cover_image": "https://images.unsplash.com/photo-1633356122544-f134324a6cee?auto=format&fit=crop&w=1200&q=80",
                "status": PostStatus.PUBLISHED,
                "author_id": author.id,
                "category_id": cat_map["web-development"].id,
                "tags": [tag_map["react"], tag_map["tailwindcss"]]
            },
            {
                "title": "Designing Premium UI with Dark Mode & Micro-Animations",
                "slug": "designing-premium-ui-dark-mode-micro-animations",
                "summary": "Explore modern design aesthetics including glassmorphism, curated color palettes, CSS variables, and fluid transitions that wow users.",
                "content": """# Designing Premium UI with Dark Mode & Micro-Animations

In today's digital landscape, functional code is only half the battle. Delivering a **visually captivating**, polished user experience sets great products apart from mediocre ones.

## Glassmorphism & Depth

Combining subtle border highlights, dark translucent backgrounds (`backdrop-filter: blur(12px)`), and gentle shadow layers creates realistic spatial hierarchy.

> "Design is not just what it looks like and feels like. Design is how it works." — Steve Jobs

### Checklist for Modern UI:

- High-contrast legible typography
- Smooth hover micro-transitions (`transition-all duration-300`)
- Dynamic dark/light mode toggle
- Clean empty states and loading skeletons""",
                "cover_image": "https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?auto=format&fit=crop&w=1200&q=80",
                "status": PostStatus.PUBLISHED,
                "author_id": admin.id,
                "category_id": cat_map["ui-ux-design"].id,
                "tags": [tag_map["tailwindcss"], tag_map["react"]]
            },
            {
                "title": "Demystifying JWT Authentication and Refresh Tokens",
                "slug": "demystifying-jwt-authentication-and-refresh-tokens",
                "summary": "A deep dive into secure token-based authentication, password hashing with bcrypt, stateless session management, and refresh token rotation.",
                "content": """# Demystifying JWT Authentication and Refresh Tokens

JSON Web Tokens (JWT) are an open, industry standard RFC 7519 method for representing claims securely between two parties.

## Access Token vs Refresh Token

- **Access Token**: Short-lived token (e.g. 15-60 mins) passed in the `Authorization: Bearer <token>` header with every API request.
- **Refresh Token**: Longer-lived token (e.g. 7-30 days) used exclusively to fetch a new access token when expired.

```python
# Passlib Bcrypt Hashing
hashed_password = get_password_hash("user_secret_password")
is_valid = verify_password("user_secret_password", hashed_password)
```""",
                "cover_image": "https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=1200&q=80",
                "status": PostStatus.PUBLISHED,
                "author_id": author.id,
                "category_id": cat_map["web-development"].id,
                "tags": [tag_map["jwt"], tag_map["fastapi"], tag_map["python"]]
            }
        ]

        for pdata in posts_data:
            existing_post = db.query(Post).filter(Post.slug == pdata["slug"]).first()
            if not existing_post:
                tags_list = pdata.pop("tags")
                post = Post(**pdata)
                post.tags = tags_list
                db.add(post)
                db.commit()
                db.refresh(post)

                # Add sample comments
                comment1 = Comment(
                    content="Great article! The explanation on Dependency Injection was super helpful.",
                    author_id=author.id,
                    post_id=post.id
                )
                db.add(comment1)
                db.commit()

        print("[+] Database seeding completed successfully!")

    except Exception as e:
        print(f"[-] Error seeding database: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
