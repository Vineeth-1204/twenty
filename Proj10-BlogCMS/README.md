# Full-Stack Blog CMS (FastAPI + React + Vite)

A modern, production-style Blog Content Management System (CMS) built with **FastAPI**, **SQLAlchemy**, **JWT Authentication**, **Pydantic v2**, and **React 18 (Vite)** with **Tailwind CSS**.

---

## 🌟 Features

### 🌐 Public Website
- **Hero Featured Article**: Top publication highlighted with badge, author, and reading time.
- **Article Feed**: Responsive grid of published articles with cover image zoom effects, category badges, author avatars, reading time estimation, and view counter.
- **Dynamic Search Modal (⌘K)**: Global search across title, content, tags, and category.
- **Category & Tag Filters**: Filter feed by category pills or tag cloud.
- **Blog Detail Page**: Formatted Markdown rendering with `react-markdown`, reading time, share button, tag pills, related articles, and comments.
- **Interactive Comments**: Authenticated users can comment; authors/admins can delete comments.

### 🔐 Authentication & Security
- User registration and login using **bcrypt** password hashing (72-byte safe handling).
- **JWT Access Token** & **Refresh Token** rotation mechanism.
- Role-based authorization (`User` vs `Admin`).
- Protected frontend routes and API endpoints via **FastAPI Dependency Injection**.

### 🛠️ Admin Dashboard & Editor
- **Analytics Overview**: Cards showing total posts, published articles, drafts, and total views count.
- **Status Toggle**: Instant toggle between `PUBLISHED` and `DRAFT`.
- **Rich Blog Editor**:
  - Title, summary, category dropdown, tag selector.
  - Cover image file upload (`POST /api/v1/upload`) with drag-and-drop & live thumbnail preview.
  - **Live Markdown Preview**: Tabbed editor switching between raw markdown input and live HTML preview.
- **Category Manager**: Modal for quick creation of new categories.

---

## 🏗️ Architecture & Core Concepts Explained

### 1. FastAPI Architecture & APIRouter
FastAPI structures endpoints using modular `APIRouter` instances (`app/routers/`). Each router handles a domain (auth, categories, tags, posts, comments, upload) and is included into `main.py` with `/api/v1` prefix.

### 2. Dependency Injection (`Depends`)
FastAPI's dependency injection system injects reusable logic directly into router handlers:
- `get_db`: Provides a dedicated database session per request and guarantees cleanup (`yield db` / `finally db.close()`).
- `get_current_user`: Extracts JWT bearer tokens from the request header, decodes payload, and returns the authenticated user object.
- `get_current_admin`: Verifies that `user.is_admin` is True.

### 3. Pydantic Schemas vs SQLAlchemy ORM Models
- **SQLAlchemy Models** (`app/models/`): Represent database tables (`users`, `posts`, `categories`, `tags`, `comments`, `post_tags` association).
- **Pydantic Schemas** (`app/schemas/`): Enforce strict input validation (e.g. `EmailStr`, required fields) and control output serialization format.

### 4. Interactive OpenAPI Docs (Swagger)
FastAPI automatically generates interactive Swagger documentation available at:
`http://127.0.0.1:8000/docs`

---

## 🚀 Quick Start Guide

### 1. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Create Python virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
.\venv\Scripts\activate
# Linux/macOS:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Seed the database with mock users, categories, tags, and articles
python seed.py

# Start FastAPI server
uvicorn main:app --reload --port 8000
```
Backend API will run at `http://127.0.0.1:8000`.

### 2. Frontend Setup

```bash
# Navigate to frontend directory
cd frontend

# Install npm packages
npm install

# Start Vite dev server
npm run dev
```
Frontend will run at `http://localhost:5173`.

---

## 🔑 Demo Account Credentials

| Role | Email | Password |
|---|---|---|
| **Admin Lead** | `admin@blogcms.com` | `admin123` |
| **Regular Author** | `john@example.com` | `password123` |

---

## 🐳 Docker Deployment

To launch the full stack with PostgreSQL database:

```bash
docker-compose up --build
```
This boots PostgreSQL on port 5432 and FastAPI on port 8000.
