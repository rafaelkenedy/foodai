# FoodAI Assistant - API Documentation

## Base URL
```
http://localhost:8000
```

## Authentication
Currently, the API uses session-based identification. No authentication is required for this prototype version.

---

## Chat Endpoints

### Send Message
Send a text or image message to the AI assistant.

**Endpoint:** `POST /api/chat/message`

**Request Body:**
```json
{
  "session_id": "string",
  "user_id": "string",
  "message": "string",
  "image_data": "string (optional, base64 encoded)"
}
```

**Response:**
```json
{
  "session_id": "string",
  "message": "string",
  "suggestions": ["string"] (optional),
  "timestamp": "2024-01-01T12:00:00"
}
```

**Example:**
```bash
curl -X POST "http://localhost:8000/api/chat/message" \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "session-123",
    "user_id": "user-456",
    "message": "Sugira um prato vegetariano"
  }'
```

### Get Conversation History
Retrieve the conversation history for a session.

**Endpoint:** `GET /api/chat/history/{session_id}`

**Response:**
```json
[
  {
    "role": "user",
    "content": "string",
    "message_type": "text",
    "image_url": "string (optional)",
    "timestamp": "2024-01-01T12:00:00"
  }
]
```

### Clear Conversation History
Clear all messages for a session.

**Endpoint:** `DELETE /api/chat/history/{session_id}`

**Response:**
```json
{
  "message": "Conversation history cleared successfully"
}
```

---

## Preferences Endpoints

### Get User Preferences
Get dietary preferences for a user.

**Endpoint:** `GET /api/preferences/{user_id}`

**Response:**
```json
{
  "user_id": "string",
  "dietary_restrictions": ["string"],
  "favorite_cuisines": ["string"],
  "allergies": ["string"],
  "spice_level": "string (optional)",
  "budget_range": "string (optional)"
}
```

### Update User Preferences
Update user dietary preferences.

**Endpoint:** `PUT /api/preferences/{user_id}`

**Request Body:**
```json
{
  "user_id": "string",
  "dietary_restrictions": ["Vegetariano", "Sem glúten"],
  "favorite_cuisines": ["Italiana", "Japonesa"],
  "allergies": ["Amendoim"],
  "spice_level": "Médio",
  "budget_range": "Moderado"
}
```

**Response:** Same as request body

---

## Orders Endpoints

### Create Order
Create a new food order.

**Endpoint:** `POST /api/orders`

**Request Body:**
```json
{
  "user_id": "string",
  "items": [
    {
      "food_item_id": "string",
      "quantity": 1,
      "price": 29.90
    }
  ]
}
```

**Response:**
```json
{
  "order": {
    "id": "string",
    "user_id": "string",
    "items": [...],
    "total_price": 29.90,
    "status": "pending",
    "created_at": "2024-01-01T12:00:00",
    "updated_at": "2024-01-01T12:00:00"
  },
  "message": "Pedido criado com sucesso! 🎉"
}
```

### Get User Orders
Get all orders for a user.

**Endpoint:** `GET /api/orders/user/{user_id}`

**Response:** Array of order objects

### Get Order by ID
Get details of a specific order.

**Endpoint:** `GET /api/orders/{order_id}`

**Response:** Single order object

---

## Error Responses

All endpoints may return error responses in the following format:

```json
{
  "detail": "Error message description"
}
```

**Common HTTP Status Codes:**
- `200` - Success
- `404` - Not Found
- `500` - Internal Server Error

---

## Interactive Documentation

Visit `http://localhost:8000/docs` for interactive Swagger UI documentation where you can test all endpoints directly in your browser.
