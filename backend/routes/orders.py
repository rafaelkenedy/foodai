from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import uuid
from datetime import datetime

from models import Order, OrderRequest, OrderResponse, OrderStatus
from database import get_db, DBOrder

router = APIRouter(prefix="/api/orders", tags=["orders"])


@router.post("", response_model=OrderResponse)
async def create_order(request: OrderRequest, db: Session = Depends(get_db)):
    """Create a new order."""
    try:
        # Calculate total price
        total_price = sum(item.price * item.quantity for item in request.items)
        
        # Create order
        order = DBOrder(
            id=str(uuid.uuid4()),
            user_id=request.user_id,
            items=[item.dict() for item in request.items],
            total_price=total_price,
            status=OrderStatus.PENDING.value,
            created_at=datetime.now(),
            updated_at=datetime.now()
        )
        
        db.add(order)
        db.commit()
        db.refresh(order)
        
        order_response = Order(
            id=order.id,
            user_id=order.user_id,
            items=request.items,
            total_price=order.total_price,
            status=OrderStatus(order.status),
            created_at=order.created_at,
            updated_at=order.updated_at
        )
        
        return OrderResponse(
            order=order_response,
            message="Pedido criado com sucesso! 🎉"
        )
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating order: {str(e)}")


@router.get("/user/{user_id}", response_model=List[Order])
async def get_user_orders(user_id: str, db: Session = Depends(get_db)):
    """Get all orders for a user."""
    try:
        orders = db.query(DBOrder).filter(
            DBOrder.user_id == user_id
        ).order_by(DBOrder.created_at.desc()).all()
        
        return [
            Order(
                id=order.id,
                user_id=order.user_id,
                items=order.items,
                total_price=order.total_price,
                status=OrderStatus(order.status),
                created_at=order.created_at,
                updated_at=order.updated_at
            )
            for order in orders
        ]
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error retrieving orders: {str(e)}")


@router.get("/{order_id}", response_model=Order)
async def get_order(order_id: str, db: Session = Depends(get_db)):
    """Get a specific order by ID."""
    order = db.query(DBOrder).filter(DBOrder.id == order_id).first()
    
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    return Order(
        id=order.id,
        user_id=order.user_id,
        items=order.items,
        total_price=order.total_price,
        status=OrderStatus(order.status),
        created_at=order.created_at,
        updated_at=order.updated_at
    )
