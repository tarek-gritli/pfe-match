from __future__ import annotations
from typing import Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models import User, Student, Enterprise, UserRole
from app.schemas import StudentRegisterDTO, EnterpriseRegisterDTO
from app.core.security import get_password_hash, verify_password


def register_student(dto: StudentRegisterDTO, db: Session) -> User:
    """Register a new student user"""
    # Check if email already exists
    existing_user = db.query(User).filter(User.email == dto.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create user
    user = User(
        email=dto.email,
        password_hash=get_password_hash(dto.password),
        role=UserRole.STUDENT,
        is_active=True,
        profile_completed=False
    )
    db.add(user)
    db.flush()  # Get user.id before committing
    
    # Create student profile with basic info
    student = Student(
        user_id=user.id,
        first_name=dto.first_name,
        last_name=dto.last_name
    )
    db.add(student)
    db.commit()
    db.refresh(user)
    
    return user


def register_enterprise(dto: EnterpriseRegisterDTO, db: Session) -> User:
    """Register a new enterprise user"""
    # Check if email already exists
    existing_user = db.query(User).filter(User.email == dto.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create user
    user = User(
        email=dto.email,
        password_hash=get_password_hash(dto.password),
        role=UserRole.ENTERPRISE,
        is_active=True,
        profile_completed=False
    )
    db.add(user)
    db.flush()  # Get user.id before committing
    
    # Create enterprise profile with basic info
    enterprise = Enterprise(
        user_id=user.id,
        company_name=dto.company_name,
        industry=dto.industry
    )
    db.add(enterprise)
    db.commit()
    db.refresh(user)
    
    return user

Optional[User]
def authenticate_user(email: str, password: str, db: Session) -> User | None:
    """Authenticate user with email and password"""
    user = db.query(User).filter(User.email == email).first()
    
    if not user:
        return None
    
    if not verify_password(password, user.password_hash):
        return None
    
    return user

Optional[User]
def get_user_by_id(user_id: int, db: Session) -> User | None:
    """Get user by ID"""
    return db.query(User).filter(User.id == user_id).first()

Optional[User]
def get_user_by_email(email: str, db: Session) -> User | None:
    """Get user by email"""
    return db.query(User).filter(User.email == email).first()
