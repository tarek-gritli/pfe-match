from fastapi import FastAPI
from fastapi import FastAPI, Body
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os
from app.models.student import Student
from typing import Optional, List, Dict, Any
from app.pfe.router import router as pfe_router
from app.applications.router import router as applicant_router
from app.dashboard.router import router as dashboard_router

from app.api.routes.auth import router as auth_router
from app.api.routes.student import router as student_router
from app.api.routes.entreprise import router as enterprise_router
from app.db.database import Base, engine
app = FastAPI(title="Student Profile API")

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="PFE Match API",
    description="API for matching students with enterprises for internships",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create uploads directory
os.makedirs("uploads", exist_ok=True)

# Mount static files for uploads
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# Register routers so the API endpoints are actually available
app.include_router(pfe_router)
app.include_router(applicant_router)
app.include_router(dashboard_router)

# Include routers
app.include_router(auth_router)
app.include_router(student_router)
app.include_router(enterprise_router)


@app.get("/")
def root():
    return {"message": "Welcome to PFE Match API"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}