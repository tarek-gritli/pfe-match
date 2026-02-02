from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.database import SessionLocal
from app.models import PFEOffer, Application

router = APIRouter(prefix="/api/dashboard")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/statistics")
def stats(db: Session = Depends(get_db)):
    pfes = db.query(PFEOffer).all()
    apps = db.query(Application).all()

    return {
        "activePFEs": len([p for p in pfes if p.status == "open"]),
        "totalApplicants": len(apps),
        "topApplicants": len([a for a in apps if a.match_rate > 80]),
        "avgMatchRate": int(sum(a.match_rate for a in apps) / len(apps)) if apps else 0
    }
