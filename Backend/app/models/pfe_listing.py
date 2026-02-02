from sqlalchemy import Column, Integer, String, ForeignKey, Boolean, Text, JSON
from sqlalchemy.orm import relationship
from app.db.database import Base

class PFEStatus(str, enum.Enum):
    OPEN = "open"
    CLOSED = "closed"

class PFEListing(Base):
    __tablename__ = "pfe_listings"

    id = Column(String, primary_key=True, index=True)
    title = Column(String, nullable=False, index=True)
    category = Column(String, nullable=False)
    duration = Column(String, nullable=False)
    description = Column(Text)
    department = Column(String)
    status = Column(Enum(PFEStatus), default=PFEStatus.OPEN, nullable=False)
    company_id = Column(String, ForeignKey("companies.id"))
    posted_date = Column(DateTime(timezone=True), server_default=func.now())
    deadline = Column(DateTime(timezone=True))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relations
    company = relationship("Company", back_populates="pfe_listings")
    skills = relationship("Skill", secondary=pfe_skills, back_populates="pfe_listings")
    applicants = relationship("Applicant", back_populates="pfe_listing")