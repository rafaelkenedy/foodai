from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import uuid
from datetime import datetime

from models import ChatRequest, ChatResponse, ChatMessage, MessageRole, MessageType
from database import get_db, DBConversation, DBUser
from langchain_service import food_ai_service

router = APIRouter(prefix="/api/chat", tags=["chat"])


@router.post("/message", response_model=ChatResponse)
async def send_message(request: ChatRequest, db: Session = Depends(get_db)):
    """Send a text or image message to the AI assistant."""
    try:
        # Get user preferences
        user = db.query(DBUser).filter(DBUser.user_id == request.user_id).first()
        user_preferences = None
        
        if user:
            user_preferences = {
                "dietary_restrictions": user.dietary_restrictions or [],
                "favorite_cuisines": user.favorite_cuisines or [],
                "allergies": user.allergies or [],
                "spice_level": user.spice_level,
                "budget_range": user.budget_range
            }
        
        # Save user message to database
        user_message = DBConversation(
            id=str(uuid.uuid4()),
            session_id=request.session_id,
            user_id=request.user_id,
            role=MessageRole.USER.value,
            content=request.message,
            message_type=MessageType.TEXT_WITH_IMAGE.value if request.image_data else MessageType.TEXT.value,
            timestamp=datetime.now()
        )
        db.add(user_message)
        
        # Process message with AI
        if request.image_data:
            ai_response = await food_ai_service.process_image_message(
                session_id=request.session_id,
                message=request.message,
                image_data=request.image_data,
                user_preferences=user_preferences
            )
        else:
            ai_response = await food_ai_service.process_text_message(
                session_id=request.session_id,
                message=request.message,
                user_preferences=user_preferences
            )
        
        # Save AI response to database
        ai_message = DBConversation(
            id=str(uuid.uuid4()),
            session_id=request.session_id,
            user_id=request.user_id,
            role=MessageRole.ASSISTANT.value,
            content=ai_response,
            message_type=MessageType.TEXT.value,
            timestamp=datetime.now()
        )
        db.add(ai_message)
        db.commit()
        
        return ChatResponse(
            session_id=request.session_id,
            message=ai_response,
            timestamp=datetime.now()
        )
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error processing message: {str(e)}")


@router.get("/history/{session_id}", response_model=List[ChatMessage])
async def get_conversation_history(session_id: str, db: Session = Depends(get_db)):
    """Get conversation history for a session."""
    try:
        conversations = db.query(DBConversation).filter(
            DBConversation.session_id == session_id
        ).order_by(DBConversation.timestamp).all()
        
        messages = [
            ChatMessage(
                role=MessageRole(conv.role),
                content=conv.content,
                message_type=MessageType(conv.message_type),
                image_url=conv.image_url,
                timestamp=conv.timestamp
            )
            for conv in conversations
        ]
        
        return messages
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error retrieving history: {str(e)}")


@router.delete("/history/{session_id}")
async def clear_conversation_history(session_id: str, db: Session = Depends(get_db)):
    """Clear conversation history for a session."""
    try:
        # Delete from database
        db.query(DBConversation).filter(
            DBConversation.session_id == session_id
        ).delete()
        db.commit()
        
        # Clear from memory
        food_ai_service.clear_memory(session_id)
        
        return {"message": "Conversation history cleared successfully"}
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error clearing history: {str(e)}")
