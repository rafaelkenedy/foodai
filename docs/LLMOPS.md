# LLMOps Best Practices - Lessons from FoodAI Assistant

Este documento captura os aprendizados práticos sobre LLMOps (Large Language Model Operations) obtidos durante o desenvolvimento do FoodAI Assistant.

## 📚 Índice
1. [Gerenciamento de Contexto](#gerenciamento-de-contexto)
2. [Prompt Engineering](#prompt-engineering)
3. [Processamento Multimodal](#processamento-multimodal)
4. [Otimização de Custos](#otimização-de-custos)
5. [Monitoramento e Observabilidade](#monitoramento-e-observabilidade)
6. [Tratamento de Erros](#tratamento-de-erros)

---

## 1. Gerenciamento de Contexto

### Problema
LLMs têm janelas de contexto limitadas. Conversas longas podem exceder esse limite, resultando em perda de informação ou erros.

### Solução Implementada

```python
from langchain.memory import ConversationBufferMemory

# Memória por sessão
self.memories: Dict[str, ConversationBufferMemory] = {}

def get_or_create_memory(self, session_id: str):
    if session_id not in self.memories:
        self.memories[session_id] = ConversationBufferMemory(
            memory_key="history",
            return_messages=False
        )
    return self.memories[session_id]
```

### Best Practices
- ✅ **Isolar conversas por sessão** - Cada usuário/sessão tem sua própria memória
- ✅ **Limpar memória antiga** - Implementar TTL ou limpeza manual
- ✅ **Resumir conversas longas** - Usar summarization para manter contexto essencial
- ⚠️ **Monitorar tamanho do contexto** - Evitar exceder limites do modelo

### Alternativas
- `ConversationSummaryMemory` - Resume conversas automaticamente
- `ConversationBufferWindowMemory` - Mantém apenas N mensagens recentes
- `ConversationTokenBufferMemory` - Limita por número de tokens

---

## 2. Prompt Engineering

### Estrutura de Prompt Efetiva

```python
template = """Você é o FoodAI, um assistente virtual inteligente e amigável.

Características da sua personalidade:
- Entusiasta e apaixonado por comida
- Prestativo e atencioso com preferências do usuário
- Conhecedor de diversas culinárias

Preferências do usuário:
{user_preferences}

Histórico da conversa:
{history}

Usuário: {input}

FoodAI:"""
```

### Princípios Aplicados

#### 1. **Definição Clara de Persona**
- Estabeleça personalidade e tom de voz
- Defina limites e escopo de atuação
- Use exemplos de comportamento desejado

#### 2. **Contexto Estruturado**
```python
def _build_preferences_context(self, preferences: Dict) -> str:
    context_parts = ["Preferências do usuário:"]
    
    if preferences.get("dietary_restrictions"):
        context_parts.append(f"- Restrições: {', '.join(preferences['dietary_restrictions'])}")
    
    if preferences.get("allergies"):
        context_parts.append(f"- Alergias: {', '.join(preferences['allergies'])}")
    
    return "\n".join(context_parts)
```

#### 3. **Instruções Específicas para Tarefas**
- Para análise de imagens: "Identifique o prato, descreva ingredientes, sugira similares"
- Para recomendações: "Considere preferências, restrições e histórico"

### Técnicas Avançadas

#### Few-Shot Learning
```python
examples = """
Exemplo 1:
Usuário: Quero algo leve
FoodAI: Que tal uma salada Caesar com frango grelhado? 🥗

Exemplo 2:
Usuário: Tenho alergia a frutos do mar
FoodAI: Entendido! Vou evitar sugerir pratos com frutos do mar.
"""
```

#### Chain-of-Thought
```python
prompt = """
Antes de responder:
1. Analise as preferências do usuário
2. Considere restrições alimentares
3. Verifique o histórico de pedidos
4. Sugira opções personalizadas
"""
```

---

## 3. Processamento Multimodal

### Integração com Gemini

```python
async def process_image_message(self, message: str, image_data: str):
    # Decode imagem
    image_bytes = base64.b64decode(image_data)
    image = Image.open(BytesIO(image_bytes))
    
    # Usar API multimodal do Gemini
    model = genai.GenerativeModel(settings.gemini_model)
    response = model.generate_content([prompt, image])
    
    return response.text
```

### Otimizações

#### 1. **Compressão de Imagens**
```python
from PIL import Image

def optimize_image(image_path: str, max_size: int = 1024):
    img = Image.open(image_path)
    img.thumbnail((max_size, max_size), Image.Resampling.LANCZOS)
    return img
```

#### 2. **Validação de Formato**
```python
ALLOWED_FORMATS = ['JPEG', 'PNG', 'WEBP']

if image.format not in ALLOWED_FORMATS:
    raise ValueError(f"Formato não suportado: {image.format}")
```

#### 3. **Limite de Tamanho**
```python
MAX_IMAGE_SIZE = 4 * 1024 * 1024  # 4MB

if len(image_bytes) > MAX_IMAGE_SIZE:
    raise ValueError("Imagem muito grande")
```

---

## 4. Otimização de Custos

### Escolha do Modelo

| Modelo | Uso Recomendado | Custo Relativo |
|--------|----------------|----------------|
| Gemini 1.5 Flash | Conversas rápidas, alta frequência | Baixo |
| Gemini 1.5 Pro | Análises complexas, raciocínio profundo | Alto |

### Estratégias de Redução de Custos

#### 1. **Cache de Respostas Comuns**
```python
from functools import lru_cache

@lru_cache(maxsize=100)
def get_common_response(query_type: str):
    # Respostas pré-definidas para perguntas frequentes
    pass
```

#### 2. **Batching de Requisições**
```python
# Agrupar múltiplas perguntas em uma única chamada
questions = ["Pergunta 1", "Pergunta 2", "Pergunta 3"]
combined_prompt = "\n".join([f"{i+1}. {q}" for i, q in enumerate(questions)])
```

#### 3. **Streaming de Respostas**
```python
# Usar streaming para melhor UX sem custo adicional
for chunk in model.generate_content(prompt, stream=True):
    yield chunk.text
```

#### 4. **Monitoramento de Uso**
```python
import logging

def log_api_call(tokens_used: int, cost: float):
    logging.info(f"API Call - Tokens: {tokens_used}, Cost: ${cost:.4f}")
```

---

## 5. Monitoramento e Observabilidade

### Métricas Importantes

#### 1. **Latência**
```python
import time

start_time = time.time()
response = await llm.apredict(input=message)
latency = time.time() - start_time

# Log latency
logger.info(f"LLM Response Time: {latency:.2f}s")
```

#### 2. **Taxa de Sucesso**
```python
success_count = 0
error_count = 0

try:
    response = await llm.apredict(input=message)
    success_count += 1
except Exception as e:
    error_count += 1
    logger.error(f"LLM Error: {e}")
```

#### 3. **Qualidade de Respostas**
```python
def evaluate_response_quality(response: str) -> float:
    # Métricas simples
    has_emoji = any(char in response for char in "🍕🍔🍜")
    is_long_enough = len(response) > 50
    is_relevant = "comida" in response.lower() or "prato" in response.lower()
    
    score = sum([has_emoji, is_long_enough, is_relevant]) / 3
    return score
```

---

## 6. Tratamento de Erros

### Estratégias de Resiliência

#### 1. **Retry com Backoff Exponencial**
```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=4, max=10)
)
async def call_llm_with_retry(prompt: str):
    return await llm.apredict(input=prompt)
```

#### 2. **Fallback Responses**
```python
async def get_ai_response(message: str):
    try:
        return await call_llm(message)
    except Exception as e:
        logger.error(f"LLM failed: {e}")
        return "Desculpe, estou com dificuldades no momento. Tente novamente em instantes."
```

#### 3. **Circuit Breaker**
```python
class CircuitBreaker:
    def __init__(self, failure_threshold: int = 5):
        self.failure_count = 0
        self.failure_threshold = failure_threshold
        self.is_open = False
    
    async def call(self, func, *args, **kwargs):
        if self.is_open:
            raise Exception("Circuit breaker is open")
        
        try:
            result = await func(*args, **kwargs)
            self.failure_count = 0
            return result
        except Exception as e:
            self.failure_count += 1
            if self.failure_count >= self.failure_threshold:
                self.is_open = True
            raise e
```

---

## 🎯 Checklist de LLMOps

### Antes do Deploy
- [ ] Prompts testados e validados
- [ ] Limites de contexto configurados
- [ ] Sistema de retry implementado
- [ ] Logging e monitoramento configurados
- [ ] Custos estimados e orçamento definido
- [ ] Fallbacks para erros implementados

### Em Produção
- [ ] Monitorar latência e throughput
- [ ] Rastrear custos por usuário/sessão
- [ ] Coletar feedback de qualidade
- [ ] Analisar conversas problemáticas
- [ ] Ajustar prompts baseado em dados reais
- [ ] Otimizar cache e batching

### Manutenção Contínua
- [ ] Revisar logs de erro semanalmente
- [ ] Atualizar prompts mensalmente
- [ ] Avaliar novos modelos trimestralmente
- [ ] Treinar equipe em melhores práticas
- [ ] Documentar aprendizados e padrões

---

## 📖 Recursos Adicionais

- [LangChain Documentation](https://python.langchain.com/)
- [Google Gemini API Guide](https://ai.google.dev/docs)
- [Prompt Engineering Guide](https://www.promptingguide.ai/)
- [LLMOps: Best Practices](https://www.databricks.com/glossary/llmops)

---

**💡 Lembre-se:** LLMOps é um campo em evolução. Continue experimentando, medindo e otimizando!
