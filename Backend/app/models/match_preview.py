from sqlalchemy import Column, Integer, Float, String, Text, ForeignKey, DateTime, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
from app.db.database import Base


class MatchPreview(Base):
    """
    Stores cached match score calculations for student-PFE combinations.
    This prevents recalculating the match score every time a student opens a PFE detail.
    """
    __tablename__ = "match_previews"

    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)
    pfe_listing_id = Column(Integer, ForeignKey("pfe_listings.id"), nullable=False)
    
    # Match score data
    match_score = Column(Float, nullable=False)
    explanation = Column(Text, nullable=True)
    matched_skills = Column(JSON, nullable=True)
    missing_skills = Column(JSON, nullable=True)
    recommendations = Column(Text, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    student = relationship("Student", backref="match_previews")
    pfe_listing = relationship("PFEListing", backref="match_previews")
