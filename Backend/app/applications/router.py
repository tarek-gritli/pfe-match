from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.database import SessionLocal
from app.applications.models import Application

router = APIRouter(prefix="/api/applicants")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("")
def get_applicants(db: Session = Depends(get_db)):
    apps = db.query(Application).all()
    return [
        {
            "id": a.id,
            "name": a.student_name,
            "email": a.email,
            "university": a.university,
            "fieldOfStudy": a.field_of_study,
            "matchRate": a.match_rate,
            "status": a.status,
            "pfeId": a.pfe_id,
            "applicationDate": a.created_at
        } for a in apps
    ]

@router.patch("/{id}/status")
def update_status(id: int, payload: dict, db: Session = Depends(get_db)):
    app = db.query(Application).get(id)
    app.status = payload["status"]
    db.commit()
    return app
