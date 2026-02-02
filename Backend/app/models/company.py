from sqlalchemy import Column, Integer, String, DateTime, func, ForeignKey, Boolean, Text, JSON
from sqlalchemy.orm import relationship
from app.db.database import Base

class Company(Base):
    __tablename__ = "companies"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String)
    logo_url = Column(String)
    industry = Column(String)
    website = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relations
    pfe_listings = relationship("PFEListing", back_populates="company")