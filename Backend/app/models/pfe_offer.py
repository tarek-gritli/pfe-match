from sqlalchemy import Column, String, Integer, Text, ForeignKey, Table
from sqlalchemy.orm import relationship
from app.db.database import Base

# Association table for pfe_offers <-> skills (declare with extend_existing for hot reloads)
pfe_skills = Table(
    "pfe_skills",
    Base.metadata,
    Column("pfe_id", ForeignKey("pfe_offers.id", ondelete="CASCADE")),
    Column("skill_id", ForeignKey("skills.id", ondelete="CASCADE")),
    extend_existing=True
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

    # Use string names to avoid circular imports
    skills = relationship("Skill", secondary=pfe_skills, back_populates="pfes")
    applications = relationship("Application", back_populates="pfe", cascade="all, delete-orphan", passive_deletes=True)
