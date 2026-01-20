from typing import List, Optional

class Profile:
    def __init__(
        self,
        name: str,
        title: str,
        university: str,
        location: str,
        image_url: str,
        summary: str
    ):
        self.name = name
        self.title = title
        self.university = university
        self.location = location
        self.image_url = image_url
        self.summary = summary

class Skill:
    def __init__(self, name: str):
        self.name = name

class Tool:
    def __init__(self, name: str):
        self.name = name

class Resume:
    def __init__(self, filename: str, last_updated: str, size: str):
        self.filename = filename
        self.last_updated = last_updated
        self.size = size

class Student:
    def __init__(
        self,
        id: int,
        profile: Profile,
        skills: List[Skill],
        tools: List[Tool],
        resume: Optional[Resume] = None,
        profile_integrity: int = 0
    ):
        self.id = id
        self.profile = profile
        self.skills = skills
        self.tools = tools
        self.resume = resume
        self.profile_integrity = profile_integrity

    def to_dict(self):
        return {
            "profileIntegrity": self.profile_integrity,
            "profile": {
                "name": self.profile.name,
                "title": self.profile.title,
                "university": self.profile.university,
                "location": self.profile.location,
                "imageUrl": self.profile.image_url,
                "summary": self.profile.summary
            },
            "skills": [{"name": skill.name} for skill in self.skills],
            "tools": [{"name": tool.name} for tool in self.tools],
            "resume": {
                "filename": self.resume.filename,
                "lastUpdated": self.resume.last_updated,
                "size": self.resume.size
            } if self.resume else None
        }