from sqlalchemy import Column, String, Integer, Text, ForeignKey, Table
from sqlalchemy.orm import relationship
from app.db.database import Base

pfe_skills = Table(
    "pfe_skills",
    Base.metadata,
    Column("pfe_id", ForeignKey("pfe_offers.id")),
    Column("skill_id", ForeignKey("skills.id"))
)

class PFEOffer(Base):
    __tablename__ = "pfe_offers"

    id = Column(Integer, primary_key=True)
    title = Column(String)
    category = Column(String)
    duration = Column(String)
    description = Column(Text)
    department = Column(String)
    status = Column(String)

    skills = relationship("Skill", secondary=pfe_skills, back_populates="pfes")
    applications = relationship("Application", back_populates="pfe")
