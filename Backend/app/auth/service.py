from sqlalchemy.orm import Session
from models import User, UserRole, Student, Entreprise
from core.security import get_password_hash, verify_password
from fastapi import HTTPException
from schemas import RegisterDTO


def register_user(dto : RegisterDTO, db: Session) -> User:

    existing = db.query(User).filter(User.email == dto.email).first()
    if existing:
        raise HTTPException(400, "Email already exists")

    user = User(
        email=dto.email,
        password_hash=get_password_hash(dto.password),
        role=dto.role,
        is_active=False
    )

    db.add(user)
    db.flush()

    if dto.role == UserRole.STUDENT:

        if not dto.first_name or not dto.last_name:
            raise HTTPException(400, "Missing student fields")

        profile = Student(
            user_id=user.id,
            first_name=dto.first_name,
            last_name=dto.last_name
        )

        db.add(profile)

    elif dto.role == UserRole.ENTREPRISE:

        if not dto.company_name or not dto.industry:
            raise HTTPException(400, "Missing entreprise fields")

        profile = Entreprise(
            user_id=user.id,
            company_name=dto.company_name,
            industry=dto.industry
        )

        db.add(profile)

    db.commit()
    return user


def authenticate(email: str, password: str, db: Session):

    user = db.query(User).filter(User.email == email).first()

    if not user:
        return None

    if not verify_password(password, user.password_hash):
        return None

    return user
