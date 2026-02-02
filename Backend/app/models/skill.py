from sqlalchemy import Column, String, Integer, Text, ForeignKey, Table, DateTime, func
from sqlalchemy.orm import relationship
from app.db.database import Base

# Association table for pfe_listings <-> skills
pfe_listing_skills = Table(
    'pfe_listing_skills',
    Base.metadata,
    Column('pfe_id', Integer, ForeignKey('pfe_listings.id', ondelete='CASCADE')),
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

    # many-to-many: pfe_listings <-> skills
    pfe_listings = relationship(
        "PFEListing",
        secondary=pfe_listing_skills,
        back_populates="skills"
    )

    def __repr__(self):
        return f"<Skill id={self.id} name={self.name}>"
