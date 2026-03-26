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

from config import HOST, PORT, API_KEY, RATE_LIMIT_PER_MINUTE, MAX_INPUT_LENGTH, AI_PROVIDER
from agent import Agent

# ====================== Logging ======================
handlers = [logging.StreamHandler()]
try:
    handlers.append(logging.FileHandler("server.log", encoding="utf-8"))
except Exception:
    pass  # Read-only filesystem (HF Spaces)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=handlers,
)
logger = logging.getLogger("mr_great_ai")

# ====================== App Setup ======================
app = FastAPI(
    title="Mr. Great AI Backend",
    description="Agentic AI backend for UCIC campus chatbot",
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
    forwarded = request.headers.get("X-Forwarded-For")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


def check_rate_limit(request: Request):
    ip = get_client_ip(request)
    now = time.time()
    rate_limit_store[ip] = [t for t in rate_limit_store[ip] if now - t < 60.0]
    if len(rate_limit_store[ip]) >= RATE_LIMIT_PER_MINUTE:
        raise HTTPException(status_code=429, detail="Rate limit exceeded")
    rate_limit_store[ip].append(now)


# ====================== API Key Auth ======================
def verify_api_key(request: Request):
    api_key = request.headers.get("X-API-Key", "")
    if api_key != API_KEY:
        logger.warning(f"Invalid API key from {get_client_ip(request)}")
        raise HTTPException(status_code=401, detail="Invalid or missing API key")


# ====================== Input Validation ======================
def sanitize_input(text: str) -> str:
    if len(text) > MAX_INPUT_LENGTH:
        text = text[:MAX_INPUT_LENGTH]
    text = "".join(c for c in text if c == "\n" or c == "\t" or (ord(c) >= 32))
    return text.strip()


# ====================== Request/Response Models ======================

class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=2000)
    session_id: Optional[str] = None

class ChatResponse(BaseModel):
    response: str
    intent: str = ""
    used_llm: bool
    rag_results: List[Dict] = []

class GeneralChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=2000)
    system_prompt: Optional[str] = Field(None, max_length=3000)
    session_id: Optional[str] = None

class GeneralChatResponse(BaseModel):
    response: str
    used_llm: bool

class RAGSearchResponse(BaseModel):
    results: List[Dict]
    total: int


# ====================== API Endpoints ======================

@app.get("/")
async def root():
    return {"name": "Mr. Great AI", "status": "running", "provider": AI_PROVIDER}


@app.get("/api/health")
async def health_check():
    stats = agent.rag.get_stats()
    return {
        "status": "ok",
        "provider": AI_PROVIDER,
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
async def rag_search(q: str, top_k: int = 3, _auth=Depends(verify_api_key)):
    if not q or not q.strip():
        raise HTTPException(status_code=400, detail="Query cannot be empty")
    results = agent.rag.search(q.strip(), top_k=top_k)
    return RAGSearchResponse(results=results, total=len(results))


@app.get("/api/rag/stats")
async def rag_stats():
    return agent.rag.get_stats()


# ====================== Run Server ======================

if __name__ == "__main__":
    import uvicorn
    logger.info(f"🚀 Starting Mr. Great AI on {HOST}:{PORT}")
    logger.info(f"📚 RAG: {agent.rag.get_stats()['total_documents']} docs")
    logger.info(f"🤖 Provider: {AI_PROVIDER}")
    uvicorn.run(app, host=HOST, port=int(PORT))
