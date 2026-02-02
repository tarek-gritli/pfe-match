from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, status
from sqlalchemy.orm import Session
import os
import uuid
from app.db.database import get_db
from app.core.dependencies import get_current_user
from app.models import Student, User, UserRole
from app.schemas import (
    StudentProfileUpdate,
    StudentProfileResponse,
    ResumeUploadResponse,
    ProfilePictureUploadResponse,
    MessageResponse,
    ResumeExtractedData
)
from app.services.cv_parser import parse_resume, parse_resume_async

router = APIRouter(prefix="/students", tags=["Students"])

# Upload directories
UPLOAD_DIR = "uploads"
RESUME_DIR = os.path.join(UPLOAD_DIR, "resumes")
PROFILE_PIC_DIR = os.path.join(UPLOAD_DIR, "profile_pictures")

# Ensure directories exist
os.makedirs(RESUME_DIR, exist_ok=True)
os.makedirs(PROFILE_PIC_DIR, exist_ok=True)


@router.get("/", response_model=list[StudentProfileResponse])
def get_all_students(
    db: Session = Depends(get_db)
):
    """Get all students"""
    students = db.query(Student).all()
    return students


@router.get("/me", response_model=StudentProfileResponse)
def get_my_profile(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if current_user.role != UserRole.STUDENT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only students can access this endpoint"
        )

    student = (
        db.query(Student)
        .filter(Student.user_id == current_user.id)
        .first()
    )

    if not student:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student profile not found"
        )

    return {
        "firstName": student.first_name,
        "lastName" : student.last_name,
        "profileImage": student.profile_picture,
        "title": student.desired_job_role,
        "university": student.university,
        "bio": student.short_bio,
        "skills": student.skills or [],
        "technologies": student.technologies or [],
        "linkedinUrl": student.linkedin_url,
        "githubUrl": student.github_url,
        "customLinkUrl": student.portfolio_url,
        "customLinkLabel": "Portfolio",
        "resumeName": student.resume_url if student.resume_url else None,
    }



@router.put("/me/profile", response_model=MessageResponse)
def complete_student_profile(
    data: StudentProfileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Complete or update student profile"""
    if current_user.role != UserRole.STUDENT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only students can access this endpoint"
        )

    student = db.query(Student).filter(Student.user_id == current_user.id).first()
    if not student:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student profile not found"
        )

    # Update profile fields
    update_data = data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        if value is not None:
            setattr(student, field, value)

    # Mark profile as completed
    current_user.profile_completed = True
    
    db.commit()
    
    return MessageResponse(message="Profile updated successfully")


@router.post("/me/profile", response_model=MessageResponse)
async def complete_student_profile_with_files(
    desired_job_role: str = Form(...),
    university: str = Form(...),
    bio: str = Form(...),
    resume: UploadFile = File(None),
    profile_picture: UploadFile = File(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Complete student profile with form data and optional file uploads.
    This endpoint accepts multipart form data for profile completion.
    """
    if current_user.role != UserRole.STUDENT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only students can access this endpoint"
        )

    student = db.query(Student).filter(Student.user_id == current_user.id).first()
    if not student:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student profile not found"
        )

    # Update text fields
    student.desired_job_role = desired_job_role
    student.university = university
    student.short_bio = bio
 
    # Handle resume upload
    if resume and resume.filename:
        if not resume.filename.endswith('.pdf'):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Only PDF files are allowed for resume"
            )
        
        content = await resume.read()
        file_ext = os.path.splitext(resume.filename)[1]
        unique_filename = f"{current_user.id}_{uuid.uuid4()}{file_ext}"
        file_path = os.path.join(RESUME_DIR, unique_filename)
        
        with open(file_path, "wb") as f:
            f.write(content)
        
        student.resume_url = file_path
        
        # Try to parse resume for additional data
        try:
            extracted_data = parse_resume(content)
            student.resume_parsed = True
            
            # Only update if fields are empty
            if extracted_data.github_url and not student.github_url:
                student.github_url = extracted_data.github_url
            if extracted_data.linkedin_url and not student.linkedin_url:
                student.linkedin_url = extracted_data.linkedin_url
            if extracted_data.skills and not student.skills:
                student.skills = extracted_data.skills
            if extracted_data.technologies and not student.technologies:
                student.technologies = extracted_data.technologies
        except Exception:
            student.resume_parsed = False

    # Handle profile picture upload
    if profile_picture and profile_picture.filename:
        allowed_types = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
        if profile_picture.content_type not in allowed_types:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Only image files (JPEG, PNG, GIF, WebP) are allowed"
            )
        
        content = await profile_picture.read()
        file_ext = os.path.splitext(profile_picture.filename)[1]
        unique_filename = f"{current_user.id}_{uuid.uuid4()}{file_ext}"
        file_path = os.path.join(PROFILE_PIC_DIR, unique_filename)
        
        with open(file_path, "wb") as f:
            f.write(content)
        
        student.profile_picture = file_path

    # Mark profile as completed
    current_user.profile_completed = True
    
    db.commit()
    
    return MessageResponse(message="Profile completed successfully")


@router.post("/me/resume", response_model=ResumeUploadResponse)
async def upload_resume(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Upload resume and extract information.
    Extracts GitHub URL, LinkedIn URL, skills, and technologies from the CV.
    """
    if current_user.role != UserRole.STUDENT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only students can access this endpoint"
        )
    
    # Validate file type
    if not file.filename.endswith('.pdf'):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only PDF files are allowed"
        )
    
    # Read file content
    content = await file.read()
    
    # Generate unique filename
    file_ext = os.path.splitext(file.filename)[1]
    unique_filename = f"{current_user.id}_{uuid.uuid4()}{file_ext}"
    file_path = os.path.join(RESUME_DIR, unique_filename)
    
    # Save file
    with open(file_path, "wb") as f:
        f.write(content)
    
    # Parse resume and extract data
    extracted_data = None
    parsing_status = "pending"
    
    try:
        extracted_data = parse_resume(content)
        parsing_status = "completed"
        
        # Update student profile with extracted data
        student = db.query(Student).filter(Student.user_id == current_user.id).first()
        if student:
            student.resume_url = file_path
            student.resume_parsed = True
            
            # Always update with extracted data from new resume
            if extracted_data.github_url:
                student.github_url = extracted_data.github_url
            if extracted_data.linkedin_url:
                student.linkedin_url = extracted_data.linkedin_url
            if extracted_data.skills:
                student.skills = extracted_data.skills
            if extracted_data.technologies:
                student.technologies = extracted_data.technologies
            
            db.commit()
    except Exception as e:
        parsing_status = f"failed: {str(e)}"
        # Still save the resume even if parsing fails
        student = db.query(Student).filter(Student.user_id == current_user.id).first()
        if student:
            student.resume_url = file_path
            db.commit()
    
    return ResumeUploadResponse(
        message="Resume uploaded successfully",
        resume_url=file_path,
        parsing_status=parsing_status,
        extracted_data=extracted_data.model_dump() if extracted_data else None
    )


@router.post("/me/profile-picture", response_model=ProfilePictureUploadResponse)
async def upload_profile_picture(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Upload profile picture"""
    if current_user.role != UserRole.STUDENT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only students can access this endpoint"
        )
    
    # Validate file type
    allowed_types = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
    if file.content_type not in allowed_types:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only image files (JPEG, PNG, GIF, WebP) are allowed"
        )
    
    # Read file content
    content = await file.read()
    
    # Generate unique filename
    file_ext = os.path.splitext(file.filename)[1]
    unique_filename = f"{current_user.id}_{uuid.uuid4()}{file_ext}"
    file_path = os.path.join(PROFILE_PIC_DIR, unique_filename)
    
    # Save file
    with open(file_path, "wb") as f:
        f.write(content)
    
    # Update student profile
    student = db.query(Student).filter(Student.user_id == current_user.id).first()
    if student:
        student.profile_picture = file_path
        db.commit()
    
    return ProfilePictureUploadResponse(
        message="Profile picture uploaded successfully",
        profile_picture_url=file_path
    )


@router.post("/parse-cv", response_model=ResumeExtractedData)
async def parse_cv(
    file: UploadFile = File(...)
):
    """
    Parse a CV/resume and extract information using LLM.
    This endpoint doesn't require authentication and doesn't save the file.
    
    Extracts:
    - GitHub URL
    - LinkedIn URL  
    - Skills (programming languages, frameworks, soft skills)
    - Technologies (tools, platforms, databases)
    
    Uses OpenAI GPT for intelligent extraction if API key is configured,
    otherwise falls back to regex-based pattern matching.
    """
    # Validate file type
    if not file.filename.endswith('.pdf'):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only PDF files are allowed"
        )
    
    # Read file content
    content = await file.read()
    
    try:
        # Use async version for better performance
        extracted_data = await parse_resume_async(content)
        return extracted_data
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to parse CV: {str(e)}"
        )


@router.post("/me/parse-resume", response_model=ResumeExtractedData)
async def parse_my_resume(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Re-parse the current user's uploaded resume using LLM.
    Useful to extract skills with updated parsing logic.
    """
    if current_user.role != UserRole.STUDENT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only students can access this endpoint"
        )
    
    student = db.query(Student).filter(Student.user_id == current_user.id).first()
    if not student:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student profile not found"
        )
    
    if not student.resume_url:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No resume uploaded yet"
        )
    
    # Read the existing resume file
    try:
        with open(student.resume_url, "rb") as f:
            content = f.read()
    except FileNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Resume file not found"
        )
    
    try:
        # Parse using LLM
        extracted_data = await parse_resume_async(content)
        
        # Update student profile with new extracted data
        student.resume_parsed = True
        if extracted_data.github_url:
            student.github_url = extracted_data.github_url
        if extracted_data.linkedin_url:
            student.linkedin_url = extracted_data.linkedin_url
        if extracted_data.skills:
            student.skills = extracted_data.skills
        if extracted_data.technologies:
            student.technologies = extracted_data.technologies
        
        db.commit()
        
        return extracted_data
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to parse resume: {str(e)}"
        )
