from sqlalchemy import Column, Integer, ForeignKey, DateTime, Text, Enum, JSON, func
from sqlalchemy.orm import relationship
from app.db.database import Base
import enum

class ApplicationStatus(str, enum.Enum):
    PENDING = "pending"
    REVIEWED = "reviewed"
    SHORTLISTED = "shortlisted"
    INTERVIEW = "interview"
    ACCEPTED = "accepted"
    REJECTED = "rejected"

class Application(Base):
    __tablename__ = "applications"

    id = Column(Integer, primary_key=True, index=True)

    # Foreign keys
    student_id = Column(Integer, ForeignKey("students.id", ondelete="CASCADE"), nullable=False)
    pfe_listing_id = Column(Integer, ForeignKey("pfe_listings.id", ondelete="CASCADE"), nullable=False)

    # Application data
    match_rate = Column(Integer, default=0)
    match_explanation = Column(Text, nullable=True)
    matched_skills = Column(JSON, nullable=True, default=list)
    missing_skills = Column(JSON, nullable=True, default=list)
    recommendations = Column(Text, nullable=True)
    status = Column(Enum(ApplicationStatus), default=ApplicationStatus.PENDING, nullable=False)
    cover_letter = Column(Text, nullable=True)
    reviewer_notes = Column(Text, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    student = relationship("Student", backref="applications")
    pfe_listing = relationship("PFEListing", back_populates="applications")
