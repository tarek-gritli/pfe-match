from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.models import PFEListing, Application
from app.models.pfe_listing import PFEStatus

router = APIRouter(prefix="/api/dashboard")


@router.get("/statistics")
def stats(db: Session = Depends(get_db)):
    pfes = db.query(PFEListing).all()
    apps = db.query(Application).all()

    return {
        "activePFEs": len([p for p in pfes if p.status == PFEStatus.OPEN]),
        "totalApplicants": len(apps),
        "topApplicants": len([a for a in apps if a.match_rate > 80]),
        "avgMatchRate": int(sum(a.match_rate for a in apps) / len(apps)) if apps else 0,
    }
