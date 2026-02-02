from sqlalchemy import Column, String, Integer, Text, ForeignKey, Table, DateTime, func
from sqlalchemy.orm import relationship
from app.db.database import Base

applicant_skills = Table(
    'applicant_skills',
    Base.metadata,
    Column('applicant_id', String, ForeignKey('applicants.id', ondelete='CASCADE')),
    Column('skill_id', Integer, ForeignKey('skills.id', ondelete='CASCADE'))
)

class Skill(Base):
    """Modèle pour les compétences"""
    __tablename__ = "skills"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False, index=True)
    category = Column(String)  # Ex: Programming, Framework, Tool
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    applicants = relationship("Applicant", secondary=applicant_skills, back_populates="skills")
