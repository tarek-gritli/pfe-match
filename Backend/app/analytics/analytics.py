"""
Routes pour les analytics et statistiques
"""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import Optional
from app.models.pfe_listing import PFEListing
from app.models.applicant import Applicant
from ..database import get_db

router = APIRouter(prefix="/analytics", tags=["Analytics"])

@router.get("/dashboard-statistics")
def get_dashboard_statistics(
    company_id: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """
    Statistiques pour le dashboard Angular
    """
    # Filtrer par company si fourni
    pfe_query = db.query(PFEListing)
    if company_id:
        pfe_query = pfe_query.filter(PFEListing.company_id == company_id)

    # PFE actifs
    active_pfes = pfe_query.filter(PFEListing.status == "open").count()

    # Total applicants
    pfe_ids = [pfe.id for pfe in pfe_query.all()]
    total_applicants = db.query(Applicant).filter(
        Applicant.pfe_id.in_(pfe_ids)
    ).count() if pfe_ids else 0

    # Top applicants (match_rate >= 80)
    top_applicants = db.query(Applicant).filter(
        Applicant.pfe_id.in_(pfe_ids),
        Applicant.match_rate >= 80
    ).count() if pfe_ids else 0

    # Taux de match moyen
    avg_match_rate = db.query(func.avg(Applicant.match_rate)).filter(
        Applicant.pfe_id.in_(pfe_ids)
    ).scalar() if pfe_ids else 0.0

    return {
        "active_pfes": active_pfes,
        "total_applicants": total_applicants,
        "top_applicants": top_applicants,
        "avg_match_rate": round(avg_match_rate or 0.0, 2)
    }