from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.database import SessionLocal
from app.pfe.schemas import PFECreate
from app.pfe.service import create_pfe
from app.models import PFEOffer, Application

router = APIRouter(prefix="/api/pfe")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/listings")
def get_all_pfes(db: Session = Depends(get_db)):
    pfes = db.query(PFEOffer).all()
    return [
        {
            "id": str(p.id),
            "title": p.title,
            "category": p.category,
            "duration": p.duration,
            "status": p.status,
            "skills": [s.name for s in p.skills],
            "applicantCount": len(p.applications)
        } for p in pfes
    ]

@router.get("/listings/{id}")
def get_pfe_by_id(id: int, db: Session = Depends(get_db)):
    p = db.query(PFEOffer).get(id)
    if not p:
        return {}
    return {
        "id": str(p.id),
        "title": p.title,
        "category": p.category,
        "duration": p.duration,
        "status": p.status,
        "skills": [s.name for s in p.skills],
        "applicantCount": len(p.applications),
        "description": p.description,
        "department": p.department
    }

@router.get("/listings/{id}/applicants")
def get_applicants_for_pfe(id: int, db: Session = Depends(get_db)):
    apps = db.query(Application).filter(Application.pfe_id == id).all()
    # get pfe title to populate 'appliedTo'
    pfe = db.query(PFEOffer).get(id)
    pfe_title = pfe.title if pfe else "Unknown"
    # reuse formatting similar to applications router
    def initials_from(name: str):
        if not name:
            return ""
        parts = name.strip().split()
        if len(parts) == 1:
            return parts[0][0].upper()
        return (parts[0][0] + parts[-1][0]).upper()

    result = []
    for a in apps:
        result.append({
            "id": str(a.id),
            "name": a.student_name,
            "initials": initials_from(a.student_name),
            "email": a.email,
            "university": a.university,
            "fieldOfStudy": a.field_of_study,
            "matchRate": a.match_rate,
            "avatarColor": getattr(a, 'avatar_color', "#6366F1"),
            "appliedTo": pfe_title,
            "pfeId": str(a.pfe_id) if a.pfe_id is not None else None,
            "applicationDate": a.created_at,
            "status": a.status,
            "skills": [],
            "resumeUrl": getattr(a, 'resume_url', None)
        })
    return result

@router.post("/listings")
def create(data: PFECreate, db: Session = Depends(get_db)):
    pfe = create_pfe(db, data)
    return {"id": str(pfe.id), **data.dict(), "applicantCount": 0}
