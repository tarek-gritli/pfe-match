"""
API Routes pour les Applicants
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app import schemas, crud_applicant, crud_pfe
from app.database import get_db

router = APIRouter(
    prefix="/applicants",
    tags=["Applicants"]
)

@router.get("", response_model=List[schemas.Applicant])
def get_all_applicants(
    skip: int = 0,
    limit: int = 100,
    pfe_id: Optional[str] = None,
    status: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """
    Récupérer tous les candidats avec filtres optionnels
    """
    applicants = crud_applicant.get_applicants(
        db,
        skip=skip,
        limit=limit,
        pfe_id=pfe_id,
        status=status
    )

    # Formater la réponse
    result = []
    for app in applicants:
        pfe = crud_pfe.get_pfe_listing(db, app.pfe_id)
        app_dict = {
            "id": app.id,
            "name": app.name,
            "email": app.email,
            "university": app.university,
            "field_of_study": app.field_of_study,
            "match_rate": app.match_rate,
            "avatar_color": app.avatar_color,
            "pfe_id": app.pfe_id,
            "application_date": app.application_date,
            "status": app.status,
            "skills": app.skills,
            "applied_to": pfe.title if pfe else "Unknown",
            "resume_url": app.resume_url,
            "created_at": app.created_at,
            "updated_at": app.updated_at,
            "initials": crud_applicant.get_initials(app.name)
        }
        result.append(app_dict)

    return result

@router.get("/recent", response_model=List[schemas.Applicant])
def get_recent_applicants(
    limit: int = 5,
    db: Session = Depends(get_db)
):
    """
    Récupérer les candidats récents (limité à 5 par défaut)
    """
    applicants = crud_applicant.get_applicants(db, skip=0, limit=limit)

    result = []
    for app in applicants:
        pfe = crud_pfe.get_pfe_listing(db, app.pfe_id)
        app_dict = {
            "id": app.id,
            "name": app.name,
            "email": app.email,
            "university": app.university,
            "field_of_study": app.field_of_study,
            "match_rate": app.match_rate,
            "avatar_color": app.avatar_color,
            "pfe_id": app.pfe_id,
            "application_date": app.application_date,
            "status": app.status,
            "skills": app.skills,
            "applied_to": pfe.title if pfe else "Unknown",
            "resume_url": app.resume_url,
            "created_at": app.created_at,
            "updated_at": app.updated_at,
            "initials": crud_applicant.get_initials(app.name)
        }
        result.append(app_dict)

    return result

@router.get("/top", response_model=List[schemas.Applicant])
def get_top_applicants(
    min_match_rate: float = 80.0,
    limit: int = 10,
    db: Session = Depends(get_db)
):
    """
    Récupérer les meilleurs candidats (taux de match >= 80%)
    """
    applicants = crud_applicant.get_top_applicants(db, min_match_rate, limit)

    result = []
    for app in applicants:
        pfe = crud_pfe.get_pfe_listing(db, app.pfe_id)
        app_dict = {
            "id": app.id,
            "name": app.name,
            "email": app.email,
            "university": app.university,
            "field_of_study": app.field_of_study,
            "match_rate": app.match_rate,
            "avatar_color": app.avatar_color,
            "pfe_id": app.pfe_id,
            "application_date": app.application_date,
            "status": app.status,
            "skills": app.skills,
            "applied_to": pfe.title if pfe else "Unknown",
            "resume_url": app.resume_url,
            "created_at": app.created_at,
            "updated_at": app.updated_at,
            "initials": crud_applicant.get_initials(app.name)
        }
        result.append(app_dict)

    return result

@router.get("/{applicant_id}", response_model=schemas.Applicant)
def get_applicant(applicant_id: str, db: Session = Depends(get_db)):
    """
    Récupérer un candidat par son ID
    """
    applicant = crud_applicant.get_applicant(db, applicant_id)
    if not applicant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Applicant not found"
        )

    pfe = crud_pfe.get_pfe_listing(db, applicant.pfe_id)

    app_dict = {
        "id": applicant.id,
        "name": applicant.name,
        "email": applicant.email,
        "university": applicant.university,
        "field_of_study": applicant.field_of_study,
        "match_rate": applicant.match_rate,
        "avatar_color": applicant.avatar_color,
        "pfe_id": applicant.pfe_id,
        "application_date": applicant.application_date,
        "status": applicant.status,
        "skills": applicant.skills,
        "applied_to": pfe.title if pfe else "Unknown",
        "resume_url": applicant.resume_url,
        "created_at": applicant.created_at,
        "updated_at": applicant.updated_at,
        "initials": crud_applicant.get_initials(applicant.name)
    }

    return app_dict

@router.post("", response_model=schemas.Applicant, status_code=status.HTTP_201_CREATED)
def create_applicant(
    applicant: schemas.ApplicantCreate,
    db: Session = Depends(get_db)
):
    """
    Créer un nouveau candidat
    """
    # Vérifier que la PFE existe
    pfe = crud_pfe.get_pfe_listing(db, applicant.pfe_id)
    if not pfe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="PFE listing not found"
        )

    # Vérifier que l'email n'existe pas déjà
    existing = db.query(crud_applicant.models.Applicant).filter(
        crud_applicant.models.Applicant.email == applicant.email
    ).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

    db_applicant = crud_applicant.create_applicant(db, applicant)

    app_dict = {
        "id": db_applicant.id,
        "name": db_applicant.name,
        "email": db_applicant.email,
        "university": db_applicant.university,
        "field_of_study": db_applicant.field_of_study,
        "match_rate": db_applicant.match_rate,
        "avatar_color": db_applicant.avatar_color,
        "pfe_id": db_applicant.pfe_id,
        "application_date": db_applicant.application_date,
        "status": db_applicant.status,
        "skills": db_applicant.skills,
        "applied_to": pfe.title,
        "resume_url": db_applicant.resume_url,
        "created_at": db_applicant.created_at,
        "updated_at": db_applicant.updated_at,
        "initials": crud_applicant.get_initials(db_applicant.name)
    }

    return app_dict

@router.patch("/{applicant_id}/status", response_model=schemas.Applicant)
def update_applicant_status(
    applicant_id: str,
    status_update: schemas.ApplicantStatusUpdate,
    db: Session = Depends(get_db)
):
    """
    Mettre à jour le statut d'un candidat
    """
    db_applicant = crud_applicant.update_applicant_status(db, applicant_id, status_update)
    if not db_applicant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Applicant not found"
        )

    pfe = crud_pfe.get_pfe_listing(db, db_applicant.pfe_id)

    app_dict = {
        "id": db_applicant.id,
        "name": db_applicant.name,
        "email": db_applicant.email,
        "university": db_applicant.university,
        "field_of_study": db_applicant.field_of_study,
        "match_rate": db_applicant.match_rate,
        "avatar_color": db_applicant.avatar_color,
        "pfe_id": db_applicant.pfe_id,
        "application_date": db_applicant.application_date,
        "status": db_applicant.status,
        "skills": db_applicant.skills,
        "applied_to": pfe.title if pfe else "Unknown",
        "resume_url": db_applicant.resume_url,
        "created_at": db_applicant.created_at,
        "updated_at": db_applicant.updated_at,
        "initials": crud_applicant.get_initials(db_applicant.name)
    }

    return app_dict

@router.put("/{applicant_id}", response_model=schemas.Applicant)
def update_applicant(
    applicant_id: str,
    applicant_update: schemas.ApplicantUpdate,
    db: Session = Depends(get_db)
):
    """
    Mettre à jour un candidat
    """
    db_applicant = crud_applicant.update_applicant(db, applicant_id, applicant_update)
    if not db_applicant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Applicant not found"
        )

    pfe = crud_pfe.get_pfe_listing(db, db_applicant.pfe_id)

    app_dict = {
        "id": db_applicant.id,
        "name": db_applicant.name,
        "email": db_applicant.email,
        "university": db_applicant.university,
        "field_of_study": db_applicant.field_of_study,
        "match_rate": db_applicant.match_rate,
        "avatar_color": db_applicant.avatar_color,
        "pfe_id": db_applicant.pfe_id,
        "application_date": db_applicant.application_date,
        "status": db_applicant.status,
        "skills": db_applicant.skills,
        "applied_to": pfe.title if pfe else "Unknown",
        "resume_url": db_applicant.resume_url,
        "created_at": db_applicant.created_at,
        "updated_at": db_applicant.updated_at,
        "initials": crud_applicant.get_initials(db_applicant.name)
    }

    return app_dict

@router.delete("/{applicant_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_applicant(applicant_id: str, db: Session = Depends(get_db)):
    """
    Supprimer un candidat
    """
    success = crud_applicant.delete_applicant(db, applicant_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Applicant not found"
        )
    return None