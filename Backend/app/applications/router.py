from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.database import SessionLocal
from app.models import Application, Student, PFEListing, User, UserRole, Enterprise
from app.db.database import get_db
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/api/applicants", tags=["Applicants"])


def _format_application(a: Application, db: Session):
    # Get student info
    student = a.student
    if not student:
        return None

    # Compute initials
    def initials_from(first_name: str, last_name: str):
        if not first_name or not last_name:
            return "?"
        return (first_name[0] + last_name[0]).upper()

    # Get PFE listing info
    pfe_title = "Unknown"
    pfe_id = None
    if a.pfe_listing:
        pfe_title = a.pfe_listing.title
        pfe_id = a.pfe_listing.id

    return {
        "id": a.id,
        "name": f"{student.first_name} {student.last_name}",
        "initials": initials_from(student.first_name, student.last_name),
        "email": student.user.email if student.user else "",
        "university": student.university or "",
        "fieldOfStudy": "",  # Can add to Student model if needed
        "matchRate": a.match_rate,
        "avatarColor": "#6366F1",
        "appliedTo": pfe_title,
        "pfeId": pfe_id,
        "applicationDate": a.created_at,
        "status": a.status.value if hasattr(a.status, "value") else a.status,
        "skills": [],
        "resumeUrl": None,  # Can add if needed
    }


@router.get("")
def get_applicants(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get all applicants for the current enterprise's PFE listings.
    Only enterprise users can access this endpoint.
    """
    # Check if user is an enterprise
    if current_user.role != UserRole.ENTERPRISE:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only enterprise users can access this endpoint"
        )
    
    # Get enterprise profile
    enterprise = db.query(Enterprise).filter(Enterprise.user_id == current_user.id).first()
    if not enterprise:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Enterprise profile not found"
        )
    
    # Get all PFE listings for this enterprise
    pfe_ids = [pfe.id for pfe in db.query(PFEListing).filter(PFEListing.enterprise_id == enterprise.id).all()]
    
    # Get applications only for this enterprise's PFE listings
    apps = db.query(Application).filter(Application.pfe_listing_id.in_(pfe_ids)).all()
    formatted = [_format_application(a, db) for a in apps]
    return [f for f in formatted if f is not None]


@router.get("/{id}")
def get_applicant_by_id(id: int, db: Session = Depends(get_db)):
    """
    Get an application by its ID
    """
    app_obj = db.query(Application).filter(Application.id == id).first()
    if not app_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Application not found"
        )

    result = _format_application(app_obj, db)
    if not result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found for this application",
        )
    return result


@router.patch("/{id}/status")
def update_status(id: int, payload: dict, db: Session = Depends(get_db)):
    from app.models.application import ApplicationStatus

    app_obj = db.query(Application).filter(Application.id == id).first()
    if not app_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Application not found"
        )

    # Update status
    new_status = payload.get("status")
    if new_status:
        try:
            app_obj.status = ApplicationStatus(new_status)
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid status: {new_status}",
            )

    db.commit()
    db.refresh(app_obj)

    result = _format_application(app_obj, db)
    if not result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found for this application",
        )
    return result
