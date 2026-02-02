from sqlalchemy.orm import Session
from app.pfe.models import PFEOffer
from app.skills.models import Skill

def create_pfe(db: Session, data):
    skills = []
    for s in data.skills:
        skill = db.query(Skill).filter_by(name=s).first()
        if not skill:
            skill = Skill(name=s)
        skills.append(skill)

    pfe = PFEOffer(
        title=data.title,
        category=data.category,
        duration=data.duration,
        description=data.description,
        department=data.department,
        status=data.status,
        skills=skills
    )

    db.add(pfe)
    db.commit()
    db.refresh(pfe)
    return pfe
