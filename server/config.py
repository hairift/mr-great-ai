"""Configuration for Mr. Great AI backend.

Supports:
- ollama_cloud: Ollama Cloud API (24/7, any network)
- deepseek: DeepSeek API
- ollama: Local Ollama (development only)
"""

import os
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))

# =================== AI PROVIDER ===================
AI_PROVIDER = os.getenv("AI_PROVIDER", "ollama_cloud")

# Ollama Cloud
OLLAMA_CLOUD_API_KEY = os.getenv("OLLAMA_CLOUD_API_KEY", "")
OLLAMA_CLOUD_BASE_URL = os.getenv("OLLAMA_CLOUD_BASE_URL", "https://api.ollama.com")
OLLAMA_CLOUD_MODEL = os.getenv("OLLAMA_CLOUD_MODEL", "deepseek-v3.1:671b-cloud")

# DeepSeek API
DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY", "")
DEEPSEEK_BASE_URL = os.getenv("DEEPSEEK_BASE_URL", "https://api.deepseek.com")
DEEPSEEK_MODEL = os.getenv("DEEPSEEK_MODEL", "deepseek-chat")

# Local Ollama
OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "deepseek-v3.1:671b-cloud")

# Server
HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", "8000"))

# RAG & Limits
RAG_TOP_K = int(os.getenv("RAG_TOP_K", "3"))
MAX_TOKENS = int(os.getenv("MAX_TOKENS", "500"))
API_KEY = os.getenv("API_KEY", "mrgreat-ucic-2024-secret-key")
RATE_LIMIT_PER_MINUTE = int(os.getenv("RATE_LIMIT_PER_MINUTE", "30"))
MAX_INPUT_LENGTH = int(os.getenv("MAX_INPUT_LENGTH", "2000"))

# Paths
DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")
DATASET_PATH = os.path.join(DATA_DIR, "ucic_dataset.json")
