from pydantic import BaseModel
from typing import List, Optional

class StudentCreate(BaseModel):
    first_name: str
    last_name: str
    field_of_study: str
    skills: List[str] = []
    technologies: List[str] = []

class StudentOut(StudentCreate):
    id: int
