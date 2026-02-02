from sqlalchemy import Column, Integer, String, ForeignKey, Text, JSON
from sqlalchemy.orm import relationship
from app.db.database import Base


class Enterprise(Base):
    """Enterprise profile model"""
    __tablename__ = "entreprise"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    
    # Basic Information (from signup)
    company_name = Column(String(200), nullable=False)
    industry = Column(String(100), nullable=False)
    
    # Profile completion fields
    company_logo = Column(String(500), nullable=True)
    location = Column(String(200), nullable=True)
    employee_count = Column(String(50), nullable=True)
    company_description = Column(Text, nullable=True)
    technologies_used = Column(JSON, nullable=True, default=list)
    
    # Additional fields
    website = Column(String(500), nullable=True)
    founded_year = Column(Integer, nullable=True)
        
    # Relationship
    user = relationship("User", back_populates="enterprise")


from typing import List, Optional
from pydantic import BaseModel, HttpUrl, Field

class EnterpriseProfileUpdate(BaseModel):
    company_name: Optional[str] = Field(None, max_length=200)
    industry: Optional[str] = Field(None, max_length=100)
    location: Optional[str] = Field(None, max_length=200)
    employee_count: Optional[str] = Field(None, max_length=50)
    company_description: Optional[str] = None
    technologies_used: Optional[List[str]] = []
    website: Optional[HttpUrl] = None
    founded_year: Optional[int] = None
    # Optional frontend-only field
    linkedin_url: Optional[HttpUrl] = None

    class Config:
        orm_mode = True
