from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel
from datetime import datetime
from app.models import User, Notification, NotificationType
from app.core.dependencies import get_current_user
from app.db.database import get_db

router = APIRouter(prefix="/api/notifications", tags=["Notifications"])


class NotificationResponse(BaseModel):
    id: int
    title: str
    message: str
    type: str
    is_read: bool
    pfe_listing_id: int | None
    application_id: int | None
    created_at: datetime

    class Config:
        from_attributes = True


class UnreadCountResponse(BaseModel):
    count: int


@router.get("", response_model=List[NotificationResponse])
def get_notifications(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    limit: int = 50,
    unread_only: bool = False
):
    """
    Get notifications for the current user.
    """
    query = db.query(Notification).filter(Notification.user_id == current_user.id)
    
    if unread_only:
        query = query.filter(Notification.is_read == False)
    
    notifications = query.order_by(Notification.created_at.desc()).limit(limit).all()
    
    return [
        {
            "id": n.id,
            "title": n.title,
            "message": n.message,
            "type": n.type.value if hasattr(n.type, "value") else n.type,
            "is_read": n.is_read,
            "pfe_listing_id": n.pfe_listing_id,
            "application_id": n.application_id,
            "created_at": n.created_at,
        }
        for n in notifications
    ]


@router.get("/unread-count", response_model=UnreadCountResponse)
def get_unread_count(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get count of unread notifications for the current user.
    """
    count = db.query(Notification).filter(
        Notification.user_id == current_user.id,
        Notification.is_read == False
    ).count()
    
    return {"count": count}


@router.post("/{notification_id}/read")
def mark_as_read(
    notification_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Mark a specific notification as read.
    """
    notification = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == current_user.id
    ).first()
    
    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found"
        )
    
    notification.is_read = True
    db.commit()
    
    return {"message": "Notification marked as read"}


@router.post("/read-all")
def mark_all_as_read(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Mark all notifications as read for the current user.
    """
    db.query(Notification).filter(
        Notification.user_id == current_user.id,
        Notification.is_read == False
    ).update({"is_read": True})
    
    db.commit()
    
    return {"message": "All notifications marked as read"}


def create_notification(
    db: Session,
    user_id: int,
    title: str,
    message: str,
    notification_type: NotificationType = NotificationType.SYSTEM,
    pfe_listing_id: int | None = None,
    application_id: int | None = None
) -> Notification:
    """
    Helper function to create a notification.
    Can be called from other modules.
    """
    notification = Notification(
        user_id=user_id,
        title=title,
        message=message,
        type=notification_type,
        pfe_listing_id=pfe_listing_id,
        application_id=application_id
    )
    
    db.add(notification)
    db.commit()
    db.refresh(notification)
    
    return notification
