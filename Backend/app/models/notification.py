from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from app.db.database import Base


class NotificationType(str, enum.Enum):
    NEW_APPLICATION = "new_application"
    APPLICATION_STATUS = "application_status"
    PFE_UPDATE = "pfe_update"
    SYSTEM = "system"


class Notification(Base):
    """Notification model for user notifications"""
    __tablename__ = "notifications"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(255), nullable=False)
    message = Column(Text, nullable=False)
    type = Column(Enum(NotificationType), default=NotificationType.SYSTEM, nullable=False)
    is_read = Column(Boolean, default=False)
    
    # Optional reference to related entities
    pfe_listing_id = Column(Integer, ForeignKey("pfe_listings.id", ondelete="SET NULL"), nullable=True)
    application_id = Column(Integer, ForeignKey("applications.id", ondelete="SET NULL"), nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    user = relationship("User", backref="notifications")
    pfe_listing = relationship("PFEListing", backref="notifications")
    application = relationship("Application", backref="notifications")
