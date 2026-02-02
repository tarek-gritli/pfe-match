from sqlalchemy import Column, Integer, String, ForeignKey, Boolean, Text, JSON, DateTime, Enum, func
from sqlalchemy.orm import relationship
import enum
from app.db.database import Base
from .skill import pfe_listing_skills

class PFEStatus(str, enum.Enum):
    OPEN = "open"
    CLOSED = "closed"

class PFEListing(Base):
    __tablename__ = "pfe_listings"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False, index=True)
    category = Column(String, nullable=False)
    duration = Column(String, nullable=False)
    description = Column(Text)
    department = Column(String)
    location = Column(String)
    status = Column(Enum(PFEStatus), default=PFEStatus.OPEN, nullable=False)
    enterprise_id = Column(Integer, ForeignKey("entreprise.id", ondelete="CASCADE"))
    posted_date = Column(DateTime(timezone=True), server_default=func.now())
    deadline = Column(DateTime(timezone=True))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relations
    enterprise = relationship("Enterprise", backref="pfe_listings")
    skills = relationship("Skill", secondary=pfe_listing_skills, back_populates="pfe_listings")
    applications = relationship("Application", back_populates="pfe_listing", cascade="all, delete-orphan", passive_deletes=True)
