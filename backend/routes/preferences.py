from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from models import UserPreferences
from database import get_db, DBUser

router = APIRouter(prefix="/api/preferences", tags=["preferences"])


@router.get("/{user_id}", response_model=UserPreferences)
async def get_user_preferences(user_id: str, db: Session = Depends(get_db)):
    """Get user preferences."""
    user = db.query(DBUser).filter(DBUser.user_id == user_id).first()
    
    if not user:
        # Create new user with default preferences
        user = DBUser(
            user_id=user_id,
            dietary_restrictions=[],
            favorite_cuisines=[],
            allergies=[]
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    
    return UserPreferences(
        user_id=user.user_id,
        dietary_restrictions=user.dietary_restrictions or [],
        favorite_cuisines=user.favorite_cuisines or [],
        allergies=user.allergies or [],
        spice_level=user.spice_level,
        budget_range=user.budget_range
    )


@router.put("/{user_id}", response_model=UserPreferences)
async def update_user_preferences(
    user_id: str,
    preferences: UserPreferences,
    db: Session = Depends(get_db)
):
    """Update user preferences."""
    user = db.query(DBUser).filter(DBUser.user_id == user_id).first()
    
    if not user:
        user = DBUser(user_id=user_id)
        db.add(user)
    
    # Update preferences
    user.dietary_restrictions = preferences.dietary_restrictions
    user.favorite_cuisines = preferences.favorite_cuisines
    user.allergies = preferences.allergies
    user.spice_level = preferences.spice_level
    user.budget_range = preferences.budget_range
    
    db.commit()
    db.refresh(user)
    
    return UserPreferences(
        user_id=user.user_id,
        dietary_restrictions=user.dietary_restrictions or [],
        favorite_cuisines=user.favorite_cuisines or [],
        allergies=user.allergies or [],
        spice_level=user.spice_level,
        budget_range=user.budget_range
    )
