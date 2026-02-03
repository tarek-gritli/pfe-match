"""
Routes pour les analytics et statistiques
"""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import Optional
from app.models import PFEListing, Application
from app.models.pfe_listing import PFEStatus
from app.db.database import get_db

router = APIRouter(prefix="/analytics", tags=["Analytics"])

@router.get("/dashboard-statistics")
def get_dashboard_statistics(
    enterprise_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    """
    Statistics for Angular dashboard
    """
    # Filter by enterprise if provided
    pfe_query = db.query(PFEListing)
    if enterprise_id:
        pfe_query = pfe_query.filter(PFEListing.enterprise_id == enterprise_id)

    # Active PFEs
    active_pfes = pfe_query.filter(PFEListing.status == PFEStatus.OPEN).count()

    # Total applications
    pfe_ids = [pfe.id for pfe in pfe_query.all()]
    total_applicants = db.query(Application).filter(
        Application.pfe_listing_id.in_(pfe_ids)
    ).count() if pfe_ids else 0

    # Top applications (match_rate >= 80)
    top_applicants = db.query(Application).filter(
        Application.pfe_listing_id.in_(pfe_ids),
        Application.match_rate >= 80
    ).count() if pfe_ids else 0

    # Average match rate
    avg_match_rate = db.query(func.avg(Application.match_rate)).filter(
        Application.pfe_listing_id.in_(pfe_ids)
    ).scalar() if pfe_ids else 0.0

    return {
        "active_pfes": active_pfes,
        "total_applicants": total_applicants,
        "top_applicants": top_applicants,
        "avg_match_rate": round(avg_match_rate or 0.0, 2)
    }