from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.database import SessionLocal
from app.applications.models import Application
from app.pfe.models import PFEOffer

router = APIRouter(prefix="/api/applicants")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def _format_application(a: Application, db: Session):
    # compute initials
    def initials_from(name: str):
        if not name:
            return ""
        parts = name.strip().split()
        if len(parts) == 1:
            return parts[0][0].upper()
        return (parts[0][0] + parts[-1][0]).upper()

    pfe_title = None
    if a.pfe_id is not None:
        pfe = db.query(PFEOffer).get(a.pfe_id)
        if pfe:
            pfe_title = pfe.title

    return {
        "id": str(a.id),
        "name": a.student_name,
        "initials": initials_from(a.student_name),
        "email": a.email,
        "university": a.university,
        "fieldOfStudy": a.field_of_study,
        "matchRate": a.match_rate,
        "avatarColor": getattr(a, 'avatar_color', "#6366F1"),
        "appliedTo": pfe_title or "Unknown",
        "pfeId": str(a.pfe_id) if a.pfe_id is not None else None,
        "applicationDate": a.created_at,
        "status": a.status,
        "skills": [],
        "resumeUrl": getattr(a, 'resume_url', None)
    }

@router.get("")
def get_applicants(db: Session = Depends(get_db)):
    apps = db.query(Application).all()
    return [ _format_application(a, db) for a in apps ]

@router.get("/{id}")
def get_applicant_by_id(id: int, db: Session = Depends(get_db)):
    """
    Récupérer un applicant par son ID
    """
    app_obj = db.query(Application).get(id)
    if not app_obj:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Applicant not found")

    return _format_application(app_obj, db)

@router.patch("/{id}/status")
def update_status(id: int, payload: dict, db: Session = Depends(get_db)):
    app_obj = db.query(Application).get(id)
    if not app_obj:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Applicant not found")

    app_obj.status = payload.get("status", app_obj.status)
    db.commit()
    db.refresh(app_obj)

    return _format_application(app_obj, db)
