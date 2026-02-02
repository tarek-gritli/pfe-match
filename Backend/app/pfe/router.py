from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.db.database import SessionLocal
from app.pfe.schemas import PFEListingResponse
from app.models import PFEListing, Application
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
            "skills": [s.name for s in p.skills] if p.skills else [],
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
        "skills": [s.name for s in p.skills] if p.skills else [],
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

@router.post("/listings")
def create_pfe_listing():
    return {"message": "Create PFE listing endpoint - to be implemented"}


@router.get("/explore", response_model=List[PFEListingResponse])
def get_pfe_listings_for_students(
    db: Session = Depends(get_db), current_user=Depends(get_current_user)
):
    """
    Get all PFE listings for student explore page.
    Returns complete listing information including company details.
    """
    # Query all PFE listings with their relationships
    pfe_listings = db.query(PFEListing).filter(PFEListing.status == "open").all()

    result = []
    for listing in pfe_listings:
        # Get applicant count
        applicant_count = len(listing.applicants) if listing.applicants else 0

        # Get skills as list of strings
        skills = [skill.name for skill in listing.skills] if listing.skills else []

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
            "id": listing.id,
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
