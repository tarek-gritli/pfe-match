from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app import schemas, crud_company
from app.database import get_db

router = APIRouter(
    prefix="/companies",
    tags=["Companies"]
)

@router.get("", response_model=List[schemas.Company])
def get_all_companies(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    companies = crud_company.get_companies(db, skip=skip, limit=limit)
    return companies

@router.get("/{company_id}", response_model=schemas.Company)
def get_company(company_id: str, db: Session = Depends(get_db)):
    company = crud_company.get_company(db, company_id)
    if not company:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Company not found"
        )
    return company

@router.post("", response_model=schemas.Company, status_code=status.HTTP_201_CREATED)
def create_company(
    company: schemas.CompanyCreate,
    db: Session = Depends(get_db)
):
    db_company = crud_company.create_company(db, company)
    return db_company

@router.put("/{company_id}", response_model=schemas.Company)
def update_company(
    company_id: str,
    company_update: schemas.CompanyBase,
    db: Session = Depends(get_db)
):
    db_company = crud_company.update_company(db, company_id, company_update)
    if not db_company:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Company not found"
        )
    return db_company

@router.delete("/{company_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_company(company_id: str, db: Session = Depends(get_db)):
    success = crud_company.delete_company(db, company_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Company not found"
        )
    return None