from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.db.database import Base

class Application(Base):
    __tablename__ = "applications"

    id = Column(Integer, primary_key=True)
    student_name = Column(String)
    email = Column(String)
    university = Column(String)
    field_of_study = Column(String)
    match_rate = Column(Integer)
    status = Column(String, default="pending")
    created_at = Column(DateTime, default=datetime.utcnow)

    pfe_id = Column(Integer, ForeignKey("pfe_offers.id"))
    pfe = relationship("PFEOffer", back_populates="applications")
