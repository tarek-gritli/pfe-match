from fastapi import FastAPI, Body
from fastapi.middleware.cors import CORSMiddleware
from app.models.student import Student
from typing import Optional, List, Dict, Any
from app.pfe.router import router as pfe_router
from app.applications.router import router as applicant_router
from app.dashboard.router import router as dashboard_router

app = FastAPI(title="Student Profile API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers so the API endpoints are actually available
app.include_router(pfe_router)
app.include_router(applicant_router)
app.include_router(dashboard_router)

"""
# Create mock student instance on server start
mock_student = Student(
    id=1,
    profile=Profile(
        name="Alexandre Dubois",
        title="SOFTWARE ENGINEERING SENIOR",
        university="Tech University of Munich",
        location="Munich, Germany",
        image_url="https://lh3.googleusercontent.com/aida-public/AB6AXuC9D10QIt--py9-2R8pwT23fv-vWtFNzrVh-kZJFJsHE_npBGu18o9oBWQvctbFyVw9lsR3tbetRjXrkd-ScYW1dh06x3up4q8Tu5SmP3lDHz6hbLFdyIBKIQaH10jvtA_TGZIEzFUSqLXr5HIuFBX0afO07jkASUTUtH9ewSg-e1MzrXzzaeU-CHQJA1yCJF_r0VA40SuqAVnophnJSndNjMFrnb5S2u5okgemJV5vH9_oVkMawZtOWHt47VBOEaxmp1LEdabs-94",
        summary="Passionate software engineering student specializing in cloud-native applications and AI integration."
    ),
    skills=[
        Skill("TypeScript"),
        Skill("Python"),
        Skill("React & Next.js"),
        Skill("PostgreSQL"),
        Skill("Docker"),
        Skill("Kubernetes")
    ],
    tools=[
        Tool("AWS (EC2, S3)"),
        Tool("Git / GitHub"),
        Tool("Jira / Agile"),
        Tool("GraphQL"),
        Tool("Terraform")
    ],
    resume=Resume(
        filename="Resume_Alexandre_D.pdf",
        last_updated="Oct 24, 2023",
        size="1.2 MB"
    ),
    profile_integrity=85
)
"""

@app.get("/students/me")
def get_my_student_profile():
    return mock_student.to_dict()

@app.post("/students/me")
def update_my_student_profile(updates: Dict[str, Any] = Body(...)):
    """
    Update student profile with provided fields.
    Accepts any combination of: profileIntegrity, profile, skills, tools, resume
    """
    
    # Update profile integrity
    if "profileIntegrity" in updates:
        mock_student.profile_integrity = updates["profileIntegrity"]
    
    # Update profile fields
    if "profile" in updates:
        profile_data = updates["profile"]
        if "name" in profile_data:
            mock_student.profile.name = profile_data["name"]
        if "title" in profile_data:
            mock_student.profile.title = profile_data["title"]
        if "university" in profile_data:
            mock_student.profile.university = profile_data["university"]
        if "location" in profile_data:
            mock_student.profile.location = profile_data["location"]
        if "imageUrl" in profile_data:
            mock_student.profile.image_url = profile_data["imageUrl"]
        if "summary" in profile_data:
            mock_student.profile.summary = profile_data["summary"]
    
    # Update skills
    if "skills" in updates:
        mock_student.skills = [Skill(skill["name"]) for skill in updates["skills"]]
    
    # Update tools
    if "tools" in updates:
        mock_student.tools = [Tool(tool["name"]) for tool in updates["tools"]]
    
    # Update resume
    if "resume" in updates:
        resume_data = updates["resume"]
        if resume_data:
            mock_student.resume = Resume(
                filename=resume_data.get("filename", ""),
                last_updated=resume_data.get("lastUpdated", ""),
                size=resume_data.get("size", "")
            )
        else:
            mock_student.resume = None
    
    return {
        "message": "Profile updated successfully",
        "data": mock_student.to_dict()
    }