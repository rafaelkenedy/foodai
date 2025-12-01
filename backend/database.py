from sqlalchemy import create_engine, Column, String, Float, DateTime, Text, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime
from config import settings

# Create database engine
engine = create_engine(
    settings.database_url,
    connect_args={"check_same_thread": False} if "sqlite" in settings.database_url else {}
)

# Create session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class for models
Base = declarative_base()


class DBUser(Base):
    """User database model."""
    __tablename__ = "users"
    
    user_id = Column(String, primary_key=True, index=True)
    created_at = Column(DateTime, default=datetime.now)
    dietary_restrictions = Column(JSON, default=list)
    favorite_cuisines = Column(JSON, default=list)
    allergies = Column(JSON, default=list)
    spice_level = Column(String, nullable=True)
    budget_range = Column(String, nullable=True)


class DBConversation(Base):
    """Conversation history database model."""
    __tablename__ = "conversations"
    
    id = Column(String, primary_key=True, index=True)
    session_id = Column(String, index=True)
    user_id = Column(String, index=True)
    role = Column(String)  # user, assistant, system
    content = Column(Text)
    message_type = Column(String)  # text, image, text_with_image
    image_url = Column(String, nullable=True)
    timestamp = Column(DateTime, default=datetime.now)


class DBOrder(Base):
    """Order database model."""
    __tablename__ = "orders"
    
    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, index=True)
    items = Column(JSON)  # List of order items
    total_price = Column(Float)
    status = Column(String)  # pending, confirmed, preparing, ready, delivered, cancelled
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)


class DBFoodItem(Base):
    """Food item database model."""
    __tablename__ = "food_items"
    
    id = Column(String, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(Text)
    price = Column(Float)
    cuisine = Column(String, index=True)
    image_url = Column(String, nullable=True)
    dietary_tags = Column(JSON, default=list)
    rating = Column(Float, nullable=True)


def init_db():
    """Initialize database tables."""
    Base.metadata.create_all(bind=engine)


def get_db():
    """Get database session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
