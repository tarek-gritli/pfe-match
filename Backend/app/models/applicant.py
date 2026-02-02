from sqlalchemy import Column, String, Float, DateTime, Enum, ForeignKey, Table, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.database import Base
import enum
from .skill import applicant_skills

class ApplicationStatus(str, enum.Enum):
    PENDING = "pending"
    REVIEWED = "reviewed"
    SHORTLISTED = "shortlisted"
    INTERVIEW = "interview"
    ACCEPTED = "accepted"
    REJECTED = "rejected"

class Applicant(Base):
    """Modèle pour les candidats"""
    __tablename__ = "applicants"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False, index=True)
    email = Column(String, unique=True, nullable=False, index=True)
    university = Column(String)
    field_of_study = Column(String)
    match_rate = Column(Float, default=0.0)
    avatar_color = Column(String, default="#6366F1")
    pfe_id = Column(String, ForeignKey("pfe_listings.id", ondelete="CASCADE"))
    application_date = Column(DateTime(timezone=True), server_default=func.now())
    status = Column(Enum(ApplicationStatus), default=ApplicationStatus.PENDING, nullable=False)
    resume_url = Column(String)
    reviewer_notes = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relations
    pfe_listing = relationship("PFEListing", back_populates="applicants")

    # many-to-many: applicants <-> skills
    skills = relationship(
        "Skill",
        secondary=applicant_skills,
        back_populates="applicants",
        passive_deletes=True
    )
