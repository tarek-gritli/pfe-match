from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os

from app.api.routes.auth import router as auth_router
from app.api.routes.student import router as student_router
from app.api.routes.entreprise import router as enterprise_router
from app.db.database import Base, engine

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
    #allow_origins=[
    #    "http://localhost:4200",  # Angular dev server
    #    "http://127.0.0.1:4200",
    #    "http://localhost:4201",
    #    "http://localhost:4202",
    #    "http://localhost:50772",
    #    "http://localhost:52174",
    #    "http://127.0.0.1:50772",
    #    "http://127.0.0.1:52174",
    #],
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create uploads directory
os.makedirs("uploads", exist_ok=True)

# Mount static files for uploads
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

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
