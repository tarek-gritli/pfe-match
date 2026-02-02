from sqlalchemy.orm import Session
from typing import List, Optional
from app import models, schemas
import uuid

def get_applicant(db: Session, applicant_id: str) -> Optional[models.Applicant]:
    """Récupérer un applicant par ID"""
    return db.query(models.Applicant).filter(models.Applicant.id == applicant_id).first()

def get_applicants(
    db: Session,
    skip: int = 0,
    limit: int = 100,
    pfe_id: Optional[str] = None,
    status: Optional[str] = None
) -> List[models.Applicant]:
    query = db.query(models.Applicant)

    if pfe_id:
        query = query.filter(models.Applicant.pfe_id == pfe_id)

    if status:
        query = query.filter(models.Applicant.status == status)

    return query.offset(skip).limit(limit).all()

def create_applicant(
    db: Session,
    applicant: schemas.ApplicantCreate
) -> models.Applicant:
    # Générer un ID unique
    applicant_id = str(uuid.uuid4())

    # Calculer le taux de match (exemple simplifié)
    match_rate = calculate_match_rate(db, applicant.pfe_id, applicant.skills)

    # Créer l'applicant
    db_applicant = models.Applicant(
        id=applicant_id,
        name=applicant.name,
        email=applicant.email,
        university=applicant.university,
        field_of_study=applicant.field_of_study,
        avatar_color=applicant.avatar_color,
        pfe_id=applicant.pfe_id,
        match_rate=match_rate,
        resume_url=applicant.resume_url,
        status=models.ApplicationStatus.PENDING
    )

    # Ajouter les compétences
    if applicant.skills:
        for skill_name in applicant.skills:
            skill = db.query(models.Skill).filter(models.Skill.name == skill_name).first()
            if not skill:
                skill = models.Skill(name=skill_name)
                db.add(skill)
            db_applicant.skills.append(skill)

    db.add(db_applicant)
    db.commit()
    db.refresh(db_applicant)
    return db_applicant

def update_applicant(
    db: Session,
    applicant_id: str,
    applicant_update: schemas.ApplicantUpdate
) -> Optional[models.Applicant]:
    db_applicant = get_applicant(db, applicant_id)
    if not db_applicant:
        return None

    update_data = applicant_update.model_dump(exclude_unset=True)

    # Gérer les skills
    if "skills" in update_data:
        skills_names = update_data.pop("skills")
        db_applicant.skills.clear()
        for skill_name in skills_names:
            skill = db.query(models.Skill).filter(models.Skill.name == skill_name).first()
            if not skill:
                skill = models.Skill(name=skill_name)
                db.add(skill)
            db_applicant.skills.append(skill)

        # Recalculer le match rate si les skills changent
        db_applicant.match_rate = calculate_match_rate(
            db,
            db_applicant.pfe_id,
            skills_names
        )

    # Mettre à jour les autres champs
    for field, value in update_data.items():
        setattr(db_applicant, field, value)

    db.commit()
    db.refresh(db_applicant)
    return db_applicant

def update_applicant_status(
    db: Session,
    applicant_id: str,
    status_update: schemas.ApplicantStatusUpdate
) -> Optional[models.Applicant]:
    db_applicant = get_applicant(db, applicant_id)
    if not db_applicant:
        return None

    db_applicant.status = status_update.status
    if status_update.reviewer_notes:
        db_applicant.reviewer_notes = status_update.reviewer_notes

    db.commit()
    db.refresh(db_applicant)
    return db_applicant

def delete_applicant(db: Session, applicant_id: str) -> bool:
    db_applicant = get_applicant(db, applicant_id)
    if not db_applicant:
        return False

    db.delete(db_applicant)
    db.commit()
    return True

def get_applicants_by_pfe(db: Session, pfe_id: str) -> List[models.Applicant]:
    return db.query(models.Applicant).filter(models.Applicant.pfe_id == pfe_id).all()

def get_top_applicants(db: Session, min_match_rate: float = 80.0, limit: int = 10) -> List[models.Applicant]:
    return db.query(models.Applicant).filter(
        models.Applicant.match_rate >= min_match_rate
    ).order_by(models.Applicant.match_rate.desc()).limit(limit).all()

def calculate_match_rate(db: Session, pfe_id: str, applicant_skills: List[str]) -> float:
    # Récupérer les compétences requises pour le PFE
    pfe = db.query(models.PFEListing).filter(models.PFEListing.id == pfe_id).first()
    if not pfe or not pfe.skills:
        return 50.0  # Match rate par défaut

    required_skills = {skill.name.lower() for skill in pfe.skills}
    applicant_skill_set = {skill.lower() for skill in applicant_skills}

    if not required_skills:
        return 50.0

    # Compétences communes
    common_skills = required_skills.intersection(applicant_skill_set)

    # Calculer le pourcentage
    match_percentage = (len(common_skills) / len(required_skills)) * 100

    # Ajouter un bonus si le candidat a des compétences supplémentaires
    extra_skills = applicant_skill_set - required_skills
    bonus = min(len(extra_skills) * 2, 10)  # Max 10% de bonus

    # Score final (max 100)
    final_score = min(match_percentage + bonus, 100)

    return round(final_score, 2)

def get_initials(name: str) -> str:
    parts = name.split()
    if len(parts) >= 2:
        return f"{parts[0][0]}{parts[1][0]}".upper()
    return name[0].upper() if name else "A"