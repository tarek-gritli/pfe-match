from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional, List
from datetime import datetime
import re
from enum import Enum


class UserRole(str, Enum):
    STUDENT = "student"
    ENTERPRISE = "enterprise"


# ==================== SIGNUP SCHEMAS ====================

class StudentRegisterDTO(BaseModel):
    """Student registration data"""
    email: EmailStr
    password: str = Field(..., min_length=8)
    first_name: str = Field(..., min_length=2, max_length=100)
    last_name: str = Field(..., min_length=2, max_length=100)
    
    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        if not re.search(r'[A-Z]', v):
            raise ValueError('Password must contain at least one uppercase letter')
        if not re.search(r'[a-z]', v):
            raise ValueError('Password must contain at least one lowercase letter')
        if not re.search(r'\d', v):
            raise ValueError('Password must contain at least one number')
        return v


class EnterpriseRegisterDTO(BaseModel):
    """Enterprise registration data"""
    email: EmailStr
    password: str = Field(..., min_length=8)
    company_name: str = Field(..., min_length=2, max_length=200)
    industry: str = Field(..., min_length=2, max_length=100)
    
    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        if not re.search(r'[A-Z]', v):
            raise ValueError('Password must contain at least one uppercase letter')
        if not re.search(r'[a-z]', v):
            raise ValueError('Password must contain at least one lowercase letter')
        if not re.search(r'\d', v):
            raise ValueError('Password must contain at least one number')
        return v


# ==================== LOGIN SCHEMA ====================

class LoginDTO(BaseModel):
    """Login credentials"""
    email: EmailStr
    password: str


# ==================== TOKEN SCHEMAS ====================

class Token(BaseModel):
    """JWT Token response"""
    access_token: str
    token_type: str = "bearer"
    user_type: str
    profile_completed: bool


class TokenData(BaseModel):
    """Token payload data"""
    user_id: Optional[int] = None
    email: Optional[str] = None
    user_type: Optional[str] = None


# ==================== PROFILE COMPLETION SCHEMAS ====================

class StudentProfileUpdate(BaseModel):
    """Update student profile (profile completion step)"""
    university: Optional[str] = Field(None, max_length=200)
    short_bio: Optional[str] = Field(None, max_length=500)
    profile_picture: Optional[str] = Field(None, max_length=500)
    desired_job_role: Optional[str] = Field(None, max_length=100)
    resume: Optional[str] = Field(None, max_length=500)
    linkedin_url: Optional[str] = None
    github_url: Optional[str] = None
    portfolio_url: Optional[str] = None
    skills: Optional[List[str]] = Field(default=None)
    technologies: Optional[List[str]] = Field(default=None)


class EnterpriseProfileUpdate(BaseModel):
    """Update enterprise profile (profile completion step)"""
    location: Optional[str] = Field(None, max_length=200)
    employee_count: Optional[str] = Field(None, max_length=50)
    company_description: Optional[str] = Field(None, max_length=2000)
    technologies_used: Optional[List[str]] = Field(default=None)
    website: Optional[str] = None
    founded_year: Optional[int] = Field(None, ge=1800, le=2030)
    company_logo: Optional[str] = Field(None, max_length=500)


# ==================== RESPONSE SCHEMAS ====================

class UserResponse(BaseModel):
    """User response after registration/login"""
    id: int
    email: EmailStr
    user_type: str
    profile_completed: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


class StudentProfileResponse(BaseModel):
    """Student profile response"""
    id: int
    user_id: int
    first_name: str
    last_name: str
    university: Optional[str] = None
    short_bio: Optional[str] = None
    profile_picture: Optional[str] = None
    desired_job_role: Optional[str] = None
    linkedin_url: Optional[str] = None
    github_url: Optional[str] = None
    portfolio_url: Optional[str] = None
    skills: Optional[List[str]] = None
    technologies: Optional[List[str]] = None
    resume_url: Optional[str] = None
    resume_parsed: bool = False
    
    class Config:
        from_attributes = True


class EnterpriseProfileResponse(BaseModel):
    """Enterprise profile response"""
    id: int
    user_id: int
    company_name: str
    industry: str
    location: Optional[str] = None
    employee_count: Optional[str] = None
    company_description: Optional[str] = None
    technologies_used: Optional[List[str]] = None
    website: Optional[str] = None
    founded_year: Optional[int] = None
    company_logo: Optional[str] = None
    
    class Config:
        from_attributes = True


# ==================== FILE UPLOAD SCHEMAS ====================

class ResumeUploadResponse(BaseModel):
    """Response after resume upload"""
    message: str
    resume_url: str
    parsing_status: str
    extracted_data: Optional[dict] = None


class ResumeExtractedData(BaseModel):
    """Data extracted from resume"""
    github_url: Optional[str] = None
    linkedin_url: Optional[str] = None
    skills: List[str] = []
    technologies: List[str] = []


class ProfilePictureUploadResponse(BaseModel):
    """Response after profile picture upload"""
    message: str
    profile_picture_url: str


class MessageResponse(BaseModel):
    """Generic message response"""
    message: str
