from pydantic import BaseModel
from typing import List, Optional

class PFECreate(BaseModel):
    title: str
    category: str
    duration: str
    description: str
    department: Optional[str]
    status: str
    skills: List[str]

class PFEResponse(BaseModel):
    id: int
    title: str
    category: str
    duration: str
    status: str
    skills: List[str]
    applicantCount: int
