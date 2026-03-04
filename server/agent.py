"""Agentic AI orchestrator for Mr. Great UCIC chatbot.

Supports three AI providers:
- ollama_cloud: Ollama Cloud API (24/7, recommended)
- deepseek: DeepSeek API 
- ollama: Local Ollama (development only)
"""

from typing import Dict, Optional
import httpx

from config import (
    AI_PROVIDER, MAX_TOKENS,
    OLLAMA_CLOUD_API_KEY, OLLAMA_CLOUD_BASE_URL, OLLAMA_CLOUD_MODEL,
    DEEPSEEK_API_KEY, DEEPSEEK_BASE_URL, DEEPSEEK_MODEL,
    OLLAMA_BASE_URL, OLLAMA_MODEL,
)
from rag_engine import RAGEngine

# Intent categories
INTENT_CAMPUS_INFO = "campus_info"
INTENT_GREETING = "greeting"
INTENT_FAREWELL = "farewell"
INTENT_THANKS = "thanks"
INTENT_OFF_TOPIC = "off_topic"
INTENT_INTEREST_TEST = "interest_test"

GREETING_PATTERNS = [
    "halo", "hai", "hi", "hello", "hey", "selamat pagi", "selamat siang",
    "selamat sore", "selamat malam", "assalamualaikum", "apa kabar",
]
FAREWELL_PATTERNS = ["bye", "dadah", "sampai jumpa", "selamat tinggal"]
THANKS_PATTERNS = ["terima kasih", "makasih", "thanks", "thank you", "thx"]
OFF_TOPIC_PATTERNS = ["tugas", "kerjain", "coding", "buatkan kode", "program", "script", "debug"]
CAMPUS_KEYWORDS = [
    "ucic", "universitas", "catur insan", "jurusan", "prodi", "fakultas",
    "visi", "misi", "rektor", "great", "logo", "filosofi", "lokasi",
    "alamat", "kampus", "kontak", "email", "telepon", "nomor", "daftar",
    "pendaftaran", "pmb", "biaya", "ukt", "spp", "beasiswa", "fasilitas",
    "akreditasi", "cirebon", "kesambi", "teknik informatika",
    "sistem informasi", "dkv", "akuntansi", "manajemen", "bisnis digital",
    "pikor", "olahraga", "dosen", "pengajar", "mata kuliah", "matkul",
    "turini", "victor asih", "viar", "linda norhan", "taufan", "sudadi",
    "bambang sugiarto", "petrus sokibi", "kusnadi", "fakhrudin", "ridho",
    "marsani asfi", "chandra lukita",
]


class Agent:
    def __init__(self):
        self.rag = RAGEngine()
        self.provider = AI_PROVIDER
        print(f"[Agent] AI Provider: {self.provider}")
        if self.provider == "ollama_cloud":
            print(f"[Agent] Model: {OLLAMA_CLOUD_MODEL}")
            print(f"[Agent] URL: {OLLAMA_CLOUD_BASE_URL}")

    def detect_intent(self, message: str) -> str:
        text = message.lower().strip()
        if "tes minat" in text or "minat bakat" in text:
            return INTENT_INTEREST_TEST
        for p in OFF_TOPIC_PATTERNS:
            if p in text:
                return INTENT_OFF_TOPIC
        for p in GREETING_PATTERNS:
            if text.startswith(p) or text == p:
                return INTENT_GREETING
        for p in FAREWELL_PATTERNS:
            if p in text:
                return INTENT_FAREWELL
        for p in THANKS_PATTERNS:
            if p in text:
                return INTENT_THANKS
        for kw in CAMPUS_KEYWORDS:
            if kw in text:
                return INTENT_CAMPUS_INFO
        return INTENT_CAMPUS_INFO

    # =================== LLM Calls ===================

    async def _call_llm(self, messages: list) -> Optional[str]:
        """Route to the correct LLM provider."""
        if self.provider == "ollama_cloud":
            return await self._call_ollama_cloud(messages)
        elif self.provider == "deepseek":
            return await self._call_deepseek(messages)
        else:
            return await self._call_ollama_local(messages)

    async def _call_ollama_cloud(self, messages: list) -> Optional[str]:
        """Call Ollama Cloud API with Bearer token auth."""
        if not OLLAMA_CLOUD_API_KEY:
            print("[Agent] Ollama Cloud API key not set!")
            return None

        # Try OpenAI-compatible format first (/v1/chat/completions)
        result = await self._try_openai_format(
            base_url=OLLAMA_CLOUD_BASE_URL,
            api_key=OLLAMA_CLOUD_API_KEY,
            model=OLLAMA_CLOUD_MODEL,
            messages=messages,
        )
        if result:
            return result

        # Fallback: try Ollama native format (/api/chat)
        result = await self._try_ollama_format(
            base_url=OLLAMA_CLOUD_BASE_URL,
            api_key=OLLAMA_CLOUD_API_KEY,
            model=OLLAMA_CLOUD_MODEL,
            messages=messages,
        )
        return result

    async def _try_openai_format(self, base_url: str, api_key: str, model: str, messages: list) -> Optional[str]:
        """OpenAI-compatible chat completions format."""
        try:
            async with httpx.AsyncClient(timeout=90.0) as client:
                resp = await client.post(
                    f"{base_url}/v1/chat/completions",
                    headers={
                        "Authorization": f"Bearer {api_key}",
                        "Content-Type": "application/json",
                    },
                    json={
                        "model": model,
                        "messages": messages,
                        "max_tokens": MAX_TOKENS,
                        "temperature": 0.7,
                    },
                )
                if resp.status_code == 200:
                    data = resp.json()
                    choices = data.get("choices", [])
                    if choices:
                        return choices[0].get("message", {}).get("content", "")
                else:
                    print(f"[Agent] OpenAI format failed: {resp.status_code}")
        except Exception as e:
            print(f"[Agent] OpenAI format error: {e}")
        return None

    async def _try_ollama_format(self, base_url: str, api_key: str, model: str, messages: list) -> Optional[str]:
        """Ollama native /api/chat format with auth."""
        try:
            async with httpx.AsyncClient(timeout=90.0) as client:
                headers = {"Content-Type": "application/json"}
                if api_key:
                    headers["Authorization"] = f"Bearer {api_key}"

                resp = await client.post(
                    f"{base_url}/api/chat",
                    headers=headers,
                    json={
                        "model": model,
                        "messages": messages,
                        "stream": False,
                        "options": {"num_predict": MAX_TOKENS, "temperature": 0.7},
                    },
                )
                if resp.status_code == 200:
                    return resp.json().get("message", {}).get("content", "")
                else:
                    print(f"[Agent] Ollama format failed: {resp.status_code}")
        except Exception as e:
            print(f"[Agent] Ollama format error: {e}")
        return None

    async def _call_deepseek(self, messages: list) -> Optional[str]:
        """Call DeepSeek API."""
        return await self._try_openai_format(
            base_url=DEEPSEEK_BASE_URL,
            api_key=DEEPSEEK_API_KEY,
            model=DEEPSEEK_MODEL,
            messages=messages,
        )

    async def _call_ollama_local(self, messages: list) -> Optional[str]:
        """Call local Ollama (no auth)."""
        return await self._try_ollama_format(
            base_url=OLLAMA_BASE_URL,
            api_key="",
            model=OLLAMA_MODEL,
            messages=messages,
        )

    # =================== Responses ===================

    def _get_greeting_response(self) -> str:
        return (
            "Halo! 👋 Saya **Mr. Great**, asisten AI dari UCIC "
            "(Universitas Catur Insan Cendekia).\n\n"
            "Saya bisa membantu kamu dengan informasi seputar:\n"
            "- 📚 Program studi & fakultas\n"
            "- 👨‍🏫 Dosen & mata kuliah\n"
            "- 🎯 Visi, misi & nilai GREAT\n"
            "- 📍 Lokasi kampus & kontak\n"
            "- 💰 Biaya kuliah & beasiswa\n"
            "- 📝 Pendaftaran mahasiswa baru\n\n"
            "Silakan tanyakan apa saja! 😊"
        )

    def _get_farewell_response(self) -> str:
        return "Sampai jumpa! 👋 Semoga informasinya bermanfaat. Jangan ragu untuk bertanya lagi ya! 😊"

    def _get_thanks_response(self) -> str:
        return "Sama-sama! 😊 Senang bisa membantu. Kalau ada pertanyaan lain, silakan tanya ya!"

    def _get_off_topic_response(self) -> str:
        return "Untuk tugas atau coding, silakan pindah ke halaman **Asisten Pintar** ya 😊\nSaya khusus membantu informasi seputar UCIC."

    def _format_rag_response(self, query: str, results: list) -> str:
        if not results:
            return "Maaf, saya tidak menemukan informasi tersebut. 😅\nCoba tanyakan seputar program studi, dosen, visi misi, lokasi kampus, atau pendaftaran."
        top = results[0]
        response = f"**{top['title']}**\n\n{top['content']}"
        if len(results) > 1:
            extras = [f"- **{r['title']}**: {r['content'][:100]}..." for r in results[1:] if r["score"] > 0.15]
            if extras:
                response += "\n\n📌 **Info terkait:**\n" + "\n".join(extras)
        return response

    # =================== Main Processing ===================

    async def process(self, message: str) -> Dict:
        """Process campus info message (RAG + LLM)."""
        intent = self.detect_intent(message)

        simple_responses = {
            INTENT_GREETING: self._get_greeting_response,
            INTENT_FAREWELL: self._get_farewell_response,
            INTENT_THANKS: self._get_thanks_response,
            INTENT_OFF_TOPIC: self._get_off_topic_response,
        }
        if intent in simple_responses:
            return {"response": simple_responses[intent](), "intent": intent, "rag_results": [], "used_llm": False}
        if intent == INTENT_INTEREST_TEST:
            return {"response": "__INTEREST_TEST__", "intent": intent, "rag_results": [], "used_llm": False}

        # Campus info: RAG + LLM
        rag_results = self.rag.search(message)
        context = self.rag.get_context(message)

        if context:
            system_prompt = (
                "Anda adalah Mr. Great, asisten AI dari UCIC Cirebon.\n"
                "1. Jawab SINGKAT, PADAT, JELAS (2-3 paragraf)\n"
                "2. Bahasa Indonesia ramah, gunakan emoji\n"
                "3. Gunakan markdown: heading (#), bold (**), bullet (-)\n"
                "4. Jawab HANYA berdasarkan konteks\n\n"
                f"KONTEKS:\n{context}"
            )
            llm_response = await self._call_llm([
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": message},
            ])
            if llm_response:
                return {"response": llm_response, "intent": intent, "rag_results": rag_results, "used_llm": True}

        return {"response": self._format_rag_response(message, rag_results), "intent": intent, "rag_results": rag_results, "used_llm": False}

    async def process_general(self, message: str, system_prompt: str = "") -> Dict:
        """Process general chat (LLM only, no RAG)."""
        if not system_prompt:
            system_prompt = (
                "Anda adalah asisten AI bernama Mr. Great dari UCIC. "
                "Jawab SINGKAT, PADAT, JELAS. Gunakan markdown jika perlu."
            )

        llm_response = await self._call_llm([
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": message},
        ])

        if llm_response:
            return {"response": llm_response, "used_llm": True}

        return {
            "response": "⚠️ **Server AI sedang tidak tersedia.** Silakan coba lagi nanti.",
            "used_llm": False,
        }
