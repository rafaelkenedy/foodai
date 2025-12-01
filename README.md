# FoodAI Assistant 🍕

Um chatbot multimodal inspirado no iFood, criado com **Google AI Studio Gemini API** e **Flutter**. Este projeto demonstra a aplicação prática de **LangChain** e **FastAPI** para criar um assistente inteligente que sugere pedidos e gerencia preferências alimentares.

## 🎯 Objetivo

Projeto focado em **aprendizado prático sobre LLMOps** e integração de IA em produtos reais, explorando:
- Conversação contextual com LangChain
- Processamento multimodal (texto + imagem)
- Gerenciamento de preferências do usuário
- Recomendações personalizadas de comida

## 🏗️ Arquitetura

```
┌─────────────────┐
│  Flutter App    │
│  (Frontend)     │
└────────┬────────┘
         │ HTTP/REST
         ▼
┌─────────────────┐
│   FastAPI       │
│   (Backend)     │
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌─────────┐ ┌──────────┐
│LangChain│ │ SQLite   │
└────┬────┘ └──────────┘
     │
     ▼
┌──────────────┐
│ Google Gemini│
│     API      │
└──────────────┘
```

## ✨ Funcionalidades

### Backend (FastAPI + LangChain)
- ✅ Integração com Google Gemini 1.5 Flash
- ✅ Gerenciamento de conversação com memória contextual
- ✅ Processamento multimodal (reconhecimento de imagens de comida)
- ✅ Sistema de preferências do usuário
- ✅ Histórico de pedidos
- ✅ API RESTful documentada (OpenAPI/Swagger)

### Frontend (Flutter)
- ✅ Interface de chat moderna inspirada no iFood
- ✅ Upload de imagens para reconhecimento de comida
- ✅ Gerenciamento de preferências alimentares
- ✅ Design responsivo com gradientes e animações
- ✅ Indicadores de digitação
- ✅ Histórico de conversas

## 🚀 Como Executar

### Pré-requisitos

- Python 3.9+
- Flutter 3.0+ (opcional, se quiser rodar o app)
- Google AI Studio API Key ([obter aqui](https://makersuite.google.com/app/apikey))

### Backend Setup

1. **Navegue até a pasta do backend:**
```bash
cd backend
```

2. **Crie um ambiente virtual:**
```bash
python -m venv venv
.\venv\Scripts\activate  # Windows
# ou
source venv/bin/activate  # Linux/Mac
```

3. **Instale as dependências:**
```bash
pip install -r requirements.txt
```

4. **Configure as variáveis de ambiente:**
```bash
# Copie o arquivo de exemplo
copy .env.example .env  # Windows
# ou
cp .env.example .env    # Linux/Mac

# Edite o arquivo .env e adicione sua API key do Google AI Studio
# GOOGLE_API_KEY=sua_chave_aqui
```

5. **Inicie o servidor:**
```bash
python main.py
```

O servidor estará rodando em `http://localhost:8000`

📚 **Documentação da API:** `http://localhost:8000/docs`

### Frontend Setup (Flutter)

1. **Navegue até a pasta do app:**
```bash
cd food_ai_app
```

2. **Instale as dependências:**
```bash
flutter pub get
```

3. **Execute o app:**
```bash
# Para Android/iOS
flutter run

# Para Web
flutter run -d chrome

# Para Windows
flutter run -d windows
```

## 📖 Documentação da API

### Endpoints Principais

#### Chat
- `POST /api/chat/message` - Enviar mensagem (texto ou imagem)
- `GET /api/chat/history/{session_id}` - Obter histórico
- `DELETE /api/chat/history/{session_id}` - Limpar histórico

#### Preferências
- `GET /api/preferences/{user_id}` - Obter preferências
- `PUT /api/preferences/{user_id}` - Atualizar preferências

#### Pedidos
- `POST /api/orders` - Criar pedido
- `GET /api/orders/user/{user_id}` - Histórico de pedidos
- `GET /api/orders/{order_id}` - Detalhes do pedido

### Exemplo de Uso da API

```python
import requests
import base64

# Enviar mensagem de texto
response = requests.post('http://localhost:8000/api/chat/message', json={
    'session_id': 'session-123',
    'user_id': 'user-456',
    'message': 'Sugira um prato italiano vegetariano'
})

# Enviar imagem
with open('pizza.jpg', 'rb') as f:
    image_data = base64.b64encode(f.read()).decode()

response = requests.post('http://localhost:8000/api/chat/message', json={
    'session_id': 'session-123',
    'user_id': 'user-456',
    'message': 'O que é essa comida?',
    'image_data': image_data
})
```

## 🧠 LLMOps - Aprendizados

### 1. Gerenciamento de Contexto
- Uso de `ConversationBufferMemory` do LangChain para manter contexto
- Limitação de tokens para controlar custos
- Limpeza de memória quando necessário

### 2. Prompt Engineering
- Prompts estruturados com personalidade definida
- Inclusão de preferências do usuário no contexto
- Instruções específicas para análise de imagens

### 3. Processamento Multimodal
- Integração nativa do Gemini para imagens
- Combinação de texto + imagem em uma única requisição
- Otimização de tamanho de imagens antes do envio

### 4. Otimização de Custos
- Uso do Gemini 1.5 Flash (mais econômico)
- Cache de respostas quando possível
- Compressão de imagens

### 5. Tratamento de Erros
- Retry logic para falhas de API
- Fallbacks para respostas padrão
- Logging detalhado para debugging

## 🎨 Design

O design foi inspirado no iFood, com:
- **Cores principais:** Vermelho (#EA1D2C) e gradientes vibrantes
- **Tipografia:** Clean e moderna
- **Animações:** Suaves e responsivas
- **UX:** Intuitiva e familiar

## 📝 Exemplos de Conversação

**Usuário:** "Sugira um prato vegetariano"

**FoodAI:** "Que tal um delicioso **Risoto de Cogumelos** 🍄? É cremoso, saboroso e totalmente vegetariano! Acompanha cogumelos frescos, queijo parmesão e um toque de vinho branco. Perfeito para um almoço especial!"

**Usuário:** [Envia foto de uma pizza]

**FoodAI:** "Que pizza maravilhosa! 🍕 Parece ser uma **Pizza Margherita** clássica, com molho de tomate, mussarela fresca, manjericão e azeite. Um dos pratos mais icônicos da culinária italiana! Quer que eu sugira pizzas similares ou outras opções italianas?"

## 🔮 Próximos Passos

- [ ] Autenticação de usuários (Firebase/Auth0)
- [ ] Integração com restaurantes reais
- [ ] Sistema de pagamento
- [ ] Rastreamento de pedidos em tempo real
- [ ] Suporte a múltiplos idiomas
- [ ] Recomendações baseadas em ML
- [ ] Notificações push
- [ ] Modo offline

## 📚 Tecnologias Utilizadas

### Backend
- **FastAPI** - Framework web moderno e rápido
- **LangChain** - Framework para aplicações com LLMs
- **Google Gemini API** - Modelo de linguagem multimodal
- **SQLAlchemy** - ORM para banco de dados
- **Pydantic** - Validação de dados
- **Uvicorn** - Servidor ASGI

### Frontend
- **Flutter** - Framework multiplataforma
- **Provider** - Gerenciamento de estado
- **HTTP** - Cliente HTTP
- **Image Picker** - Seleção de imagens

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:
1. Fork o projeto
2. Criar uma branch (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abrir um Pull Request

## 📄 Licença

Este projeto é open source e está disponível sob a licença MIT.

## 👨‍💻 Autor

Criado como projeto de aprendizado em LLMOps e integração de IA.

---

**⭐ Se este projeto foi útil para você, considere dar uma estrela!**
