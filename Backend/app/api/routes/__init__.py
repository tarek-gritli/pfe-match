from .auth import router as auth_router
from .student import router as student_router
from .entreprise import router as enterprise_router

__all__ = ["auth_router", "student_router", "enterprise_router"]
