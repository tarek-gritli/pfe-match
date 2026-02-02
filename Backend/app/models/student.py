from sqlalchemy import Column, Integer, String, ForeignKey, Boolean, Text, JSON
from sqlalchemy.orm import relationship
from app.db.database import Base


class Student(Base):
    """Student profile model"""
    __tablename__ = "students"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    
    # Basic Information (from signup)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)

    # Profile completion fields
    university = Column(String(200), nullable=True)
    profile_picture = Column(String(500), nullable=True)
    resume_url = Column(String(500), nullable=True)
    short_bio = Column(Text, nullable=True)
    desired_job_role = Column(String(100), nullable=True)
    
    # Social/Portfolio Links
    linkedin_url = Column(String(500), nullable=True)
    github_url = Column(String(500), nullable=True)
    portfolio_url = Column(String(500), nullable=True)
    
    # Skills and technologies (stored as JSON for PostgreSQL compatibility)
    skills = Column(JSON, nullable=True, default=list)
    technologies = Column(JSON, nullable=True, default=list)
    
    # Resume parsing status
    resume_parsed = Column(Boolean, default=False)
    
    # Relationship
    user = relationship("User", back_populates="student")


from pydantic import BaseModel
from typing import List, Optional



class StudentProfileUpdate(BaseModel):
    university: Optional[str] = None
    short_bio: Optional[str] = None
    desired_job_role: Optional[str] = None
    linkedin_url: Optional[str] = None
    github_url: Optional[str] = None
    portfolio_url: Optional[str] = None
    skills: Optional[List[str]] = None
    technologies: Optional[List[str]] = None
