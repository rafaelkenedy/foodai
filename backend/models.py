from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum


class MessageRole(str, Enum):
    """Message role enumeration."""
    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"


class MessageType(str, Enum):
    """Message type enumeration."""
    TEXT = "text"
    IMAGE = "image"
    TEXT_WITH_IMAGE = "text_with_image"


class ChatMessage(BaseModel):
    """Chat message model."""
    role: MessageRole
    content: str
    message_type: MessageType = MessageType.TEXT
    image_url: Optional[str] = None
    timestamp: datetime = Field(default_factory=datetime.now)


class ChatRequest(BaseModel):
    """Request model for chat endpoint."""
    session_id: str
    user_id: str
    message: str
    image_data: Optional[str] = None  # Base64 encoded image


class ChatResponse(BaseModel):
    """Response model for chat endpoint."""
    session_id: str
    message: str
    suggestions: Optional[List[str]] = None
    timestamp: datetime = Field(default_factory=datetime.now)


class UserPreferences(BaseModel):
    """User preferences model."""
    user_id: str
    dietary_restrictions: List[str] = Field(default_factory=list)
    favorite_cuisines: List[str] = Field(default_factory=list)
    allergies: List[str] = Field(default_factory=list)
    spice_level: Optional[str] = None  # mild, medium, hot
    budget_range: Optional[str] = None  # budget, moderate, premium


class FoodItem(BaseModel):
    """Food item model."""
    id: str
    name: str
    description: str
    price: float
    cuisine: str
    image_url: Optional[str] = None
    dietary_tags: List[str] = Field(default_factory=list)
    rating: Optional[float] = None


class OrderStatus(str, Enum):
    """Order status enumeration."""
    PENDING = "pending"
    CONFIRMED = "confirmed"
    PREPARING = "preparing"
    READY = "ready"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"


class OrderItem(BaseModel):
    """Order item model."""
    food_item_id: str
    quantity: int
    price: float


class Order(BaseModel):
    """Order model."""
    id: str
    user_id: str
    items: List[OrderItem]
    total_price: float
    status: OrderStatus = OrderStatus.PENDING
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)


class OrderRequest(BaseModel):
    """Request model for creating an order."""
    user_id: str
    items: List[OrderItem]


class OrderResponse(BaseModel):
    """Response model for order operations."""
    order: Order
    message: str
