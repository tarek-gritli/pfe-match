from sqlalchemy import Column, String, Integer, Text, ForeignKey, Table, DateTime, func
from sqlalchemy.orm import relationship
from app.db.database import Base

# Association tables defined once here with extend_existing to allow hot reloads
applicant_skills = Table(
    'applicant_skills',
    Base.metadata,
    Column('applicant_id', String, ForeignKey('applicants.id', ondelete='CASCADE')),
    Column('skill_id', Integer, ForeignKey('skills.id', ondelete='CASCADE')),
    extend_existing=True
)

pfe_listing_skills = Table(
    'pfe_listing_skills',
    Base.metadata,
    Column('pfe_id', String, ForeignKey('pfe_listings.id', ondelete='CASCADE')),
    Column('skill_id', Integer, ForeignKey('skills.id', ondelete='CASCADE')),
    extend_existing=True
)

class Skill(Base):
    """Model for skills and association relationships."""
    __tablename__ = "skills"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False, index=True)
    category = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # many-to-many: applicants <-> skills
    applicants = relationship(
        "Applicant",
        secondary=applicant_skills,
        back_populates="skills",
        passive_deletes=True
    )

    # many-to-many: pfe_offers <-> skills (PFEOffer uses pfe_skills table declared in pfe_offer.py)
    pfes = relationship(
        "PFEOffer",
        secondary="pfe_skills",
        back_populates="skills"
    )

    # many-to-many: pfe_listings <-> skills
    pfe_listings = relationship(
        "PFEListing",
        secondary=pfe_listing_skills,
        back_populates="skills"
    )

    def __repr__(self):
        return f"<Skill id={self.id} name={self.name}>"
