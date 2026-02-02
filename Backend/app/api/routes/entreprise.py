from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, status
from sqlalchemy.orm import Session
import os
import uuid
from app.db.database import get_db
from app.core.dependencies import get_current_user
from app.models import Enterprise, User, UserRole
from app.schemas import (
    EnterpriseProfileUpdate,
    EnterpriseProfileResponse,
    ProfilePictureUploadResponse,
    MessageResponse
)

router = APIRouter(prefix="/enterprises", tags=["Enterprises"])

# Upload directories
UPLOAD_DIR = "uploads"
LOGO_DIR = os.path.join(UPLOAD_DIR, "company_logos")

# Ensure directories exist
os.makedirs(LOGO_DIR, exist_ok=True)


@router.get("/me", response_model=EnterpriseProfileResponse)
def get_my_profile(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get current enterprise's profile mapped to frontend interface"""
    if current_user.role != UserRole.ENTERPRISE:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only enterprises can access this endpoint"
        )

    enterprise = db.query(Enterprise).filter(Enterprise.user_id == current_user.id).first()
    if not enterprise:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Enterprise profile not found"
        )

    # Map backend fields to frontend Enterprise interface
    response_data = {
        "name": enterprise.company_name,
        "logo": enterprise.company_logo,
        "industry": enterprise.industry,
        "location": enterprise.location,
        "size": enterprise.employee_count,
        "description": enterprise.company_description,
        "technologies": enterprise.technologies_used or [],
        "website": enterprise.website,
        "foundedYear": enterprise.founded_year,
        # Optional frontend-only fields
        "linkedinUrl": getattr(enterprise.user, "linkedin_url", None),
        "contactEmail": getattr(enterprise.user, "email", None)
    }

    return response_data



@router.put("/me/profile", response_model=MessageResponse)
def complete_enterprise_profile(
    data: EnterpriseProfileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Complete or update enterprise profile from frontend form"""
    if current_user.role != UserRole.ENTERPRISE:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only enterprises can access this endpoint"
        )

    enterprise = db.query(Enterprise).filter(Enterprise.user_id == current_user.id).first()
    if not enterprise:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Enterprise profile not found"
        )

    # Map frontend fields to backend model
    update_data = data.model_dump(exclude_unset=True)

    # Rename frontend field keys to backend keys
    field_mapping = {
        "company_name": "company_name",
        "industry": "industry",
        "location": "location",
        "employee_count": "employee_count",
        "company_description": "company_description",
        "technologies_used": "technologies_used",
        "website": "website",
        "founded_year": "founded_year",
        "linkedin_url": "linkedin_url",
    }

    for field, value in update_data.items():
        backend_field = field_mapping.get(field)
        if backend_field and value is not None:
            setattr(enterprise, backend_field, value)

    # Mark profile as completed
    current_user.profile_completed = True

    db.commit()

    return MessageResponse(message="Profile updated successfully")



@router.post("/me/logo", response_model=ProfilePictureUploadResponse)
async def upload_company_logo(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Upload company logo"""
    if current_user.role != UserRole.ENTERPRISE:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only enterprises can access this endpoint"
        )
    
    # Validate file type
    allowed_types = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml']
    if file.content_type not in allowed_types:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only image files (JPEG, PNG, GIF, WebP, SVG) are allowed"
        )
    
    # Read file content
    content = await file.read()
    
    # Generate unique filename
    file_ext = os.path.splitext(file.filename)[1]
    unique_filename = f"{current_user.id}_{uuid.uuid4()}{file_ext}"
    file_path = os.path.join(LOGO_DIR, unique_filename)
    
    # Save file
    with open(file_path, "wb") as f:
        f.write(content)
    
    # Update enterprise profile
    enterprise = db.query(Enterprise).filter(Enterprise.user_id == current_user.id).first()
    if enterprise:
        enterprise.company_logo = file_path
        db.commit()
    
    return ProfilePictureUploadResponse(
        message="Company logo uploaded successfully",
        profile_picture_url=file_path
    )
