from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.schemas import (
    StudentRegisterDTO,
    EnterpriseRegisterDTO,
    LoginDTO,
    Token,
    MessageResponse
)
from app.services.auth_service import (
    register_student,
    register_enterprise,
    authenticate_user
)
from app.core.security import create_access_token
from app.db.database import get_db

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register/student", response_model=Token)
def register_student_endpoint(
    dto: StudentRegisterDTO,
    db: Session = Depends(get_db)
):
    """
    Register a new student user.
    
    - **email**: Valid email address
    - **password**: Min 8 chars, 1 uppercase, 1 lowercase, 1 number
    - **first_name**: Student's first name
    - **last_name**: Student's last name
    """
    user = register_student(dto, db)
    
    token = create_access_token({
        "sub": str(user.id),
        "email": user.email,
        "role": user.role.value
    })
    
    return Token(
        access_token=token,
        token_type="bearer",
        user_type=user.role.value,
        profile_completed=user.profile_completed
    )


@router.post("/register/enterprise", response_model=Token)
def register_enterprise_endpoint(
    dto: EnterpriseRegisterDTO,
    db: Session = Depends(get_db)
):
    """
    Register a new enterprise user.
    
    - **email**: Valid business email address
    - **password**: Min 8 chars, 1 uppercase, 1 lowercase, 1 number
    - **company_name**: Company name
    - **industry**: Industry sector
    """
    user = register_enterprise(dto, db)
    
    token = create_access_token({
        "sub": str(user.id),
        "email": user.email,
        "role": user.role.value
    })
    
    return Token(
        access_token=token,
        token_type="bearer",
        user_type=user.role.value,
        profile_completed=user.profile_completed
    )


@router.post("/login", response_model=Token)
def login(
    dto: LoginDTO,
    db: Session = Depends(get_db)
):
    """
    Authenticate user and return JWT token.
    Works for both students and enterprises.
    """
    user = authenticate_user(dto.email, dto.password, db)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
            headers={"WWW-Authenticate": "Bearer"}
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is inactive"
        )

    token = create_access_token({
        "sub": str(user.id),
        "email": user.email,
        "role": user.role.value
    })
    
    return Token(
        access_token=token,
        token_type="bearer",
        user_type=user.role.value,
        profile_completed=user.profile_completed
    )
