from sqlalchemy.orm import Session
from typing import List, Optional
from app import models, schemas
import uuid

def get_company(db: Session, company_id: str) -> Optional[models.Company]:
    return db.query(models.Company).filter(models.Company.id == company_id).first()

def get_companies(
    db: Session,
    skip: int = 0,
    limit: int = 100
) -> List[models.Company]:
    return db.query(models.Company).offset(skip).limit(limit).all()

def create_company(
    db: Session,
    company: schemas.CompanyCreate
) -> models.Company:
    company_id = str(uuid.uuid4())

    db_company = models.Company(
        id=company_id,
        name=company.name,
        description=company.description,
        logo_url=company.logo_url,
        industry=company.industry,
        website=company.website
    )

    db.add(db_company)
    db.commit()
    db.refresh(db_company)
    return db_company

def update_company(
    db: Session,
    company_id: str,
    company_update: schemas.CompanyBase
) -> Optional[models.Company]:
    db_company = get_company(db, company_id)
    if not db_company:
        return None

    update_data = company_update.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        setattr(db_company, field, value)

    db.commit()
    db.refresh(db_company)
    return db_company

def delete_company(db: Session, company_id: str) -> bool:
    db_company = get_company(db, company_id)
    if not db_company:
        return False

    db.delete(db_company)
    db.commit()
    return True