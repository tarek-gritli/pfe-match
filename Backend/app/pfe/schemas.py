from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class CompanyInfo(BaseModel):
    id: str
    name: str
    logoUrl: Optional[str] = None
    industry: Optional[str] = None

    class Config:
        from_attributes = True

class PFEListingResponse(BaseModel):
    id: str
    title: str
    status: str
    category: str
    duration: str
    skills: List[str]
    applicantCount: int
    description: Optional[str] = None
    department: Optional[str] = None
    postedDate: Optional[datetime] = None
    deadline: Optional[datetime] = None
    location: Optional[str] = None
    company: CompanyInfo

    class Config:
        from_attributes = True

class PFECreate(BaseModel):
    title: str
    category: str
    duration: str
    description: str
    department: Optional[str] = None
    location: Optional[str] = None
    status: str
    company_id: str
    skills: List[str]
    deadline: Optional[datetime] = None

class PFEResponse(BaseModel):
    id: int
    title: str
    category: str
    duration: str
    status: str
    skills: List[str]
    applicantCount: int
