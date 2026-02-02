from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime
from app.pfe.schemas import PFEListingResponse, PFECreate
from app.models import PFEListing, Application, User, UserRole, Enterprise
from app.core.dependencies import get_current_user
from app.db.database import get_db

router = APIRouter(prefix="/api/pfe", tags=["PFE Listings"])


@router.get("/listings")
def get_all_pfes(db: Session = Depends(get_db)):
    pfes = db.query(PFEListing).all()
    return [
        {
            "id": p.id,
            "title": p.title,
            "category": p.category,
            "duration": p.duration,
            "status": p.status.value if hasattr(p.status, "value") else p.status,
            "skills": p.skills if p.skills else [],
            "applicantCount": len(p.applications) if p.applications else 0,
        }
        for p in pfes
    ]


@router.get("/listings/{id}")
def get_pfe_by_id(id: int, db: Session = Depends(get_db)):
    p = db.query(PFEListing).filter(PFEListing.id == id).first()
    if not p:
        raise HTTPException(status_code=404, detail="PFE listing not found")
    return {
        "id": p.id,
        "title": p.title,
        "category": p.category,
        "duration": p.duration,
        "status": p.status.value if hasattr(p.status, "value") else p.status,
        "skills": p.skills if p.skills else [],
        "applicantCount": len(p.applications) if p.applications else 0,
        "description": p.description,
        "department": p.department,
        "location": p.location,
    }


@router.get("/listings/{id}/applicants")
def get_applicants_for_pfe(id: int, db: Session = Depends(get_db)):
    # Get PFE listing
    pfe = db.query(PFEListing).filter(PFEListing.id == id).first()
    if not pfe:
        raise HTTPException(status_code=404, detail="PFE listing not found")

    # Get applications for this PFE listing
    apps = db.query(Application).filter(Application.pfe_listing_id == id).all()

    def initials_from(first_name: str, last_name: str):
        if not first_name or not last_name:
            return "?"
        return (first_name[0] + last_name[0]).upper()

    result = []
    for app in apps:
        student = app.student
        if student:
            result.append(
                {
                    "id": app.id,
                    "name": f"{student.first_name} {student.last_name}",
                    "initials": initials_from(student.first_name, student.last_name),
                    "email": student.user.email if student.user else "",
                    "university": student.university or "",
                    "fieldOfStudy": "",  # Can add to Student model if needed
                    "matchRate": app.match_rate,
                    "avatarColor": "#6366F1",
                    "appliedTo": pfe.title,
                    "pfeId": pfe.id,
                    "applicationDate": app.created_at,
                    "status": (
                        app.status.value if hasattr(app.status, "value") else app.status
                    ),
                    "skills": [],  # Can get from student.skills if relationship exists
                    "resumeUrl": None,  # Can add if needed
                }
            )
    return result


@router.post("/listings", status_code=status.HTTP_201_CREATED)
def create_pfe_listing(
    pfe_data: PFECreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Create a new PFE listing.
    Only enterprise users can create PFE listings.
    """
    # Check if user is an enterprise
    if current_user.role != UserRole.ENTERPRISE:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only enterprise users can create PFE listings",
        )

    # Verify enterprise profile exists
    enterprise = (
        db.query(Enterprise).filter(Enterprise.user_id == current_user.id).first()
    )
    if not enterprise:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Enterprise profile not found. Please complete your profile first.",
        )

    # Create the PFE listing
    new_pfe = PFEListing(
        title=pfe_data.title,
        category=pfe_data.category,
        duration=pfe_data.duration,
        description=pfe_data.description,
        department=pfe_data.department,
        location=pfe_data.location,
        status=pfe_data.status,
        skills=pfe_data.skills if pfe_data.skills else [],
        enterprise_id=enterprise.id,
        deadline=pfe_data.deadline,
        posted_date=datetime.now(),
    )

    db.add(new_pfe)
    db.commit()
    db.refresh(new_pfe)

    # Return the created PFE listing
    return {
        "id": new_pfe.id,
        "title": new_pfe.title,
        "category": new_pfe.category,
        "duration": new_pfe.duration,
        "status": (
            new_pfe.status.value if hasattr(new_pfe.status, "value") else new_pfe.status
        ),
        "skills": new_pfe.skills if new_pfe.skills else [],
        "applicantCount": 0,
        "description": new_pfe.description,
        "department": new_pfe.department,
        "location": new_pfe.location,
        "deadline": new_pfe.deadline,
        "posted_date": new_pfe.posted_date,
        "enterprise_id": new_pfe.enterprise_id,
    }


@router.get("/explore", response_model=List[PFEListingResponse])
def get_pfe_listings_for_students(
    db: Session = Depends(get_db), current_user=Depends(get_current_user)
):
    """
    Get all PFE listings for student explore page.
    Returns complete listing information including company details.
    """
    # Query all PFE listings with their relationships
    pfe_listings = db.query(PFEListing).all()

    result = []
    for listing in pfe_listings:
        # Get applicant count
        applicant_count = len(listing.applications) if listing.applications else 0

        # Get skills as list of strings
        skills = listing.skills if listing.skills else []

        # Prepare company info (from enterprise)
        company_info = None
        if listing.enterprise:
            company_info = {
                "id": str(listing.enterprise.id),
                "name": listing.enterprise.company_name,
                "logoUrl": listing.enterprise.company_logo,
                "industry": listing.enterprise.industry,
            }
        else:
            # Fallback if no enterprise is linked
            company_info = {
                "id": "unknown",
                "name": "Unknown Company",
                "logoUrl": None,
                "industry": None,
            }

        # Build the response
        listing_data = {
            "id": str(listing.id),
            "title": listing.title,
            "status": (
                listing.status.value
                if hasattr(listing.status, "value")
                else listing.status
            ),
            "category": listing.category,
            "duration": listing.duration,
            "skills": skills,
            "applicantCount": applicant_count,
            "description": listing.description,
            "department": listing.department,
            "postedDate": listing.posted_date,
            "deadline": listing.deadline,
            "location": listing.location,
            "company": company_info,
        }

        result.append(listing_data)

    return result
