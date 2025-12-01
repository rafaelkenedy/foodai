import google.generativeai as genai
from typing import Dict, Optional, List
from config import settings
import base64
from io import BytesIO
from PIL import Image

# Configure Google AI
genai.configure(api_key=settings.google_api_key)


class FoodAIService:
    """Service for FoodAI Assistant using Google Gemini API."""
    
    def __init__(self):
        """Initialize the FoodAI service."""
        # Store conversation histories by session_id
        self.chat_histories: Dict[str, List[Dict[str, str]]] = {}
        
        # System prompt for food assistant
        self.system_prompt = """Você é o FoodAI, um assistente virtual inteligente e amigável inspirado no iFood. 
Sua missão é ajudar os usuários a descobrir comidas deliciosas, fazer pedidos e gerenciar suas preferências alimentares.

Características da sua personalidade:
- Entusiasta e apaixonado por comida
- Prestativo e atencioso com preferências do usuário
- Conhecedor de diversas culinárias e pratos
- Sugere opções baseadas no histórico e preferências
- Usa emojis ocasionalmente para tornar a conversa mais amigável 🍕🍔🍜

Quando o usuário pedir sugestões (texto):
- Sugira pratos específicos e deliciosos baseados no pedido
- Descreva os pratos de forma apetitosa
- Pergunte se o usuário gostaria de ver opções de restaurantes ou fazer um pedido

Quando o usuário enviar uma imagem de comida:
- Identifique o prato com precisão
- Descreva os ingredientes visíveis
- Sugira pratos similares
- Ofereça informações nutricionais aproximadas"""
    
    def get_or_create_history(self, session_id: str) -> List[Dict[str, str]]:
        """Get or create chat message history for a session."""
        if session_id not in self.chat_histories:
            self.chat_histories[session_id] = []
        return self.chat_histories[session_id]
    
    async def process_text_message(
        self, 
        session_id: str, 
        message: str,
        user_preferences: Optional[Dict] = None
    ) -> str:
        """Process a text message and return AI response."""
        # Get chat history
        history = self.get_or_create_history(session_id)
        
        # Build conversation context
        conversation_parts = [self.system_prompt]
        
        # Add user preferences context if available
        if user_preferences:
            context = self._build_preferences_context(user_preferences)
            conversation_parts.append(context)
        
        # Add conversation history
        for msg in history:
            role = "Usuário" if msg["role"] == "user" else "FoodAI"
            conversation_parts.append(f"{role}: {msg['content']}")
        
        # Add current message
        conversation_parts.append(f"Usuário: {message}")
        conversation_parts.append("FoodAI:")
        
        full_prompt = "\n\n".join(conversation_parts)
        
        # Generate response using Gemini
        model = genai.GenerativeModel(settings.gemini_model)
        response = model.generate_content(full_prompt)
        
        # Add to history
        history.append({"role": "user", "content": message})
        history.append({"role": "assistant", "content": response.text})
        
        return response.text
    
    async def process_image_message(
        self,
        session_id: str,
        message: str,
        image_data: str,
        user_preferences: Optional[Dict] = None
    ) -> str:
        """Process a message with an image using Gemini's multimodal capabilities."""
        try:
            # Decode base64 image
            image_bytes = base64.b64decode(image_data)
            image = Image.open(BytesIO(image_bytes))
            
            # Build prompt with preferences context
            prompt = f"""{self.system_prompt}

Analise esta imagem de comida e responda à seguinte mensagem do usuário: {message}

Por favor:
1. Identifique o prato ou alimento na imagem
2. Descreva os ingredientes visíveis
3. Sugira pratos similares que o usuário possa gostar
4. Forneça informações nutricionais aproximadas se relevante
"""
            
            if user_preferences:
                context = self._build_preferences_context(user_preferences)
                prompt = f"{prompt}\n\n{context}"
            
            # Use Gemini's native multimodal API
            model = genai.GenerativeModel(settings.gemini_model)
            response = model.generate_content([prompt, image])
            
            # Add to conversation history
            history = self.get_or_create_history(session_id)
            history.append({"role": "user", "content": f"[Imagem enviada] {message}"})
            history.append({"role": "assistant", "content": response.text})
            
            return response.text
            
        except Exception as e:
            return f"Desculpe, tive um problema ao analisar a imagem. Erro: {str(e)}"
    
    def _build_preferences_context(self, preferences: Dict) -> str:
        """Build context string from user preferences."""
        context_parts = ["Preferências do usuário:"]
        
        if preferences.get("dietary_restrictions"):
            context_parts.append(f"- Restrições alimentares: {', '.join(preferences['dietary_restrictions'])}")
        
        if preferences.get("allergies"):
            context_parts.append(f"- Alergias: {', '.join(preferences['allergies'])}")
        
        if preferences.get("favorite_cuisines"):
            context_parts.append(f"- Culinárias favoritas: {', '.join(preferences['favorite_cuisines'])}")
        
        if preferences.get("spice_level"):
            context_parts.append(f"- Nível de pimenta: {preferences['spice_level']}")
        
        if preferences.get("budget_range"):
            context_parts.append(f"- Faixa de preço: {preferences['budget_range']}")
        
        return "\n".join(context_parts)
    
    def clear_memory(self, session_id: str):
        """Clear conversation memory for a session."""
        if session_id in self.chat_histories:
            del self.chat_histories[session_id]
    
    def get_conversation_history(self, session_id: str) -> List[str]:
        """Get conversation history for a session."""
        history = self.get_or_create_history(session_id)
        return [msg["content"] for msg in history]


# Global service instance
food_ai_service = FoodAIService()
