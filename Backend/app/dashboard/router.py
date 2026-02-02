from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.models import PFEListing, Application, User, UserRole, Enterprise
from app.models.pfe_listing import PFEStatus
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/api/dashboard")


@router.get("/statistics")
def stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get dashboard statistics for the logged-in enterprise.
    Only shows data for the enterprise's own PFE listings and applications.
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

    # Get only PFE listings belonging to this enterprise
    pfes = db.query(PFEListing).filter(PFEListing.enterprise_id == enterprise.id).all()

    # Get only applications for this enterprise's PFE listings
    pfe_ids = [p.id for p in pfes]
    apps = db.query(Application).filter(Application.pfe_listing_id.in_(pfe_ids)).all() if pfe_ids else []

    return {
        "activePFEs": len([p for p in pfes if p.status == PFEStatus.OPEN]),
        "totalApplicants": len(apps),
        "topApplicants": len([a for a in apps if a.match_rate > 80]),
        "avgMatchRate": int(sum(a.match_rate for a in apps) / len(apps)) if apps else 0,
    }
