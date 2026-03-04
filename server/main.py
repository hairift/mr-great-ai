"""FastAPI server for Mr. Great AI backend.

Production-ready REST API with:
- RAG-powered campus info chat (/api/chat)
- General LLM chat without RAG (/api/chat/general)
- API key authentication
- Rate limiting per IP
- Input validation & logging
"""

import time
import logging
from collections import defaultdict
from typing import Optional, List, Dict

from fastapi import FastAPI, HTTPException, Request, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from config import HOST, PORT, API_KEY, RATE_LIMIT_PER_MINUTE, MAX_INPUT_LENGTH
from agent import Agent

# ====================== Logging ======================
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler("server.log", encoding="utf-8"),
    ],
)
logger = logging.getLogger("mr_great_ai")

# ====================== App Setup ======================
app = FastAPI(
    title="Mr. Great AI Backend",
    description="Agentic AI backend for UCIC campus chatbot — production-ready with auth & rate limiting",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize agent (singleton)
agent = Agent()

# ====================== Rate Limiter ======================
rate_limit_store: Dict[str, list] = defaultdict(list)


def get_client_ip(request: Request) -> str:
    """Get client IP, respecting X-Forwarded-For from reverse proxy."""
    forwarded = request.headers.get("X-Forwarded-For")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


def check_rate_limit(request: Request):
    """Rate limiting middleware — per IP, configurable via RATE_LIMIT_PER_MINUTE."""
    ip = get_client_ip(request)
    now = time.time()
    window = 60.0  # 1 minute window

    # Clean old entries
    rate_limit_store[ip] = [t for t in rate_limit_store[ip] if now - t < window]

    if len(rate_limit_store[ip]) >= RATE_LIMIT_PER_MINUTE:
        logger.warning(f"Rate limit exceeded for IP: {ip}")
        raise HTTPException(
            status_code=429,
            detail=f"Rate limit exceeded. Maximum {RATE_LIMIT_PER_MINUTE} requests per minute.",
        )

    rate_limit_store[ip].append(now)


# ====================== API Key Auth ======================
def verify_api_key(request: Request):
    """Verify X-API-Key header matches configured API key."""
    api_key = request.headers.get("X-API-Key", "")
    if api_key != API_KEY:
        logger.warning(f"Invalid API key from {get_client_ip(request)}")
        raise HTTPException(status_code=401, detail="Invalid or missing API key")


# ====================== Input Validation ======================
def sanitize_input(text: str) -> str:
    """Basic input sanitization — limit length and strip control characters."""
    if len(text) > MAX_INPUT_LENGTH:
        text = text[:MAX_INPUT_LENGTH]
    # Remove null bytes and other control chars (keep newlines and tabs)
    text = "".join(c for c in text if c == "\n" or c == "\t" or (ord(c) >= 32))
    return text.strip()


# ====================== Request/Response Models ======================

class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=2000, description="User message")
    session_id: Optional[str] = None


class ChatResponse(BaseModel):
    response: str
    intent: str = ""
    used_llm: bool
    rag_results: List[Dict] = []


class GeneralChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=2000, description="User message")
    system_prompt: Optional[str] = Field(None, max_length=3000, description="Custom system prompt")
    session_id: Optional[str] = None


class GeneralChatResponse(BaseModel):
    response: str
    used_llm: bool


class RAGSearchResponse(BaseModel):
    results: List[Dict]
    total: int


# ====================== API Endpoints ======================

@app.get("/api/health")
async def health_check():
    """Health check — shows server status, Ollama availability, and RAG stats."""
    stats = agent.rag.get_stats()
    ollama_ok = await agent.check_ollama()
    return {
        "status": "ok",
        "ollama_available": ollama_ok,
        "rag_stats": stats,
        "rate_limit_per_minute": RATE_LIMIT_PER_MINUTE,
    }


@app.post("/api/chat", response_model=ChatResponse)
async def chat(
    request: Request,
    body: ChatRequest,
    _auth=Depends(verify_api_key),
    _rate=Depends(check_rate_limit),
):
    """Campus info chat endpoint — uses RAG + LLM for UCIC information."""
    ip = get_client_ip(request)
    message = sanitize_input(body.message)

    if not message:
        raise HTTPException(status_code=400, detail="Message cannot be empty")

    logger.info(f"[CHAT/RAG] IP={ip} msg={message[:80]}...")

    result = await agent.process(message)

    logger.info(f"[CHAT/RAG] IP={ip} intent={result['intent']} llm={result['used_llm']}")

    return ChatResponse(
        response=result["response"],
        intent=result["intent"],
        used_llm=result["used_llm"],
        rag_results=result["rag_results"],
    )


@app.post("/api/chat/general", response_model=GeneralChatResponse)
async def chat_general(
    request: Request,
    body: GeneralChatRequest,
    _auth=Depends(verify_api_key),
    _rate=Depends(check_rate_limit),
):
    """General chat endpoint — LLM only, no RAG. Used by main.dart & asisten_pintar."""
    ip = get_client_ip(request)
    message = sanitize_input(body.message)
    system_prompt = body.system_prompt or ""

    if not message:
        raise HTTPException(status_code=400, detail="Message cannot be empty")

    logger.info(f"[CHAT/GENERAL] IP={ip} msg={message[:80]}...")

    result = await agent.process_general(message, system_prompt)

    logger.info(f"[CHAT/GENERAL] IP={ip} llm={result['used_llm']}")

    return GeneralChatResponse(
        response=result["response"],
        used_llm=result["used_llm"],
    )


@app.get("/api/rag/search")
async def rag_search(
    q: str,
    top_k: int = 3,
    request: Request = None,
    _auth=Depends(verify_api_key),
):
    """Direct RAG search for testing."""
    if not q or not q.strip():
        raise HTTPException(status_code=400, detail="Query cannot be empty")

    results = agent.rag.search(q.strip(), top_k=top_k)
    return RAGSearchResponse(results=results, total=len(results))


@app.get("/api/rag/stats")
async def rag_stats():
    """Get RAG engine statistics (no auth required)."""
    return agent.rag.get_stats()


# ====================== Run Server ======================

if __name__ == "__main__":
    import uvicorn

    logger.info(f"🚀 Starting Mr. Great AI Backend on {HOST}:{PORT}")
    logger.info(f"📚 RAG Engine: {agent.rag.get_stats()['total_documents']} documents loaded")
    logger.info(f"🔑 API Key Auth: enabled")
    logger.info(f"⏱️ Rate Limit: {RATE_LIMIT_PER_MINUTE} req/min per IP")

    uvicorn.run(app, host=HOST, port=int(PORT))
