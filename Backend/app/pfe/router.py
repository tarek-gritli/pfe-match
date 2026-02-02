from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.database import SessionLocal
from app.pfe.schemas import PFECreate
from app.pfe.service import create_pfe
from app.pfe.models import PFEOffer

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
            "id": p.id,
            "title": p.title,
            "category": p.category,
            "duration": p.duration,
            "status": p.status,
            "skills": [s.name for s in p.skills],
            "applicantCount": len(p.applications)
        } for p in pfes
    ]

@router.post("/listings")
def create(data: PFECreate, db: Session = Depends(get_db)):
    pfe = create_pfe(db, data)
    return {"id": pfe.id, **data.dict(), "applicantCount": 0}
