# Deploy Mr. Great AI ke Hugging Face Spaces (GRATIS, Tanpa Credit Card!)

## Langkah-langkah (5 menit!)

### 1. Daftar Hugging Face (GRATIS)

1. Buka: https://huggingface.co/join
2. Daftar pakai **email** atau **GitHub** (TANPA credit card!)

### 2. Buat Space Baru

1. Buka: https://huggingface.co/new-space
2. Isi:
   - **Space name**: `mrgreat-ai`
   - **License**: MIT
   - **SDK**: pilih **Docker**
   - **Space hardware**: **CPU basic (Free)**
   - Klik **"Create Space"**

### 3. Upload Files

Setelah Space dibuat, kamu perlu upload file-file ini:

**Cara 1 — Via Web (paling gampang):**
1. Di halaman Space, klik **"Files"** → **"Add file"** → **"Upload files"**
2. Upload file-file berikut:

```
Dockerfile              ← sudah ada di root project
server/main.py
server/agent.py
server/config.py
server/rag_engine.py
server/requirements.txt
data/ucic_dataset.json
```

**Cara 2 — Via Git (lebih rapi):**
```bash
git clone https://huggingface.co/spaces/USERNAME/mrgreat-ai
cd mrgreat-ai
```
Copy semua file ke folder ini, lalu:
```bash
git add .
git commit -m "Deploy Mr. Great AI"
git push
```

### 4. Set Environment Variables (API Keys)

1. Di halaman Space, klik **"Settings"**
2. Scroll ke **"Repository secrets"**
3. Tambahkan:

| Secret Name | Value |
|-------------|-------|
| `AI_PROVIDER` | `ollama_cloud` |
| `OLLAMA_CLOUD_API_KEY` | `a2f97ef2effa4c5fbc99f3374aeb35b3.LlcoRRIcf4rFaBbVsaFR4DPI` |
| `OLLAMA_CLOUD_BASE_URL` | `https://api.ollama.com` |
| `OLLAMA_CLOUD_MODEL` | `deepseek-v3.1:671b-cloud` |
| `API_KEY` | `mrgreat-ucic-2024-secret-key` |

### 5. Tunggu Build Selesai

- Space akan otomatis build (~3-5 menit)
- Status berubah jadi **"Running"** ✅
- URL kamu: `https://USERNAME-mrgreat-ai.hf.space`

### 6. Update Flutter App

Edit `lib/api_config.dart`:
```dart
static String get baseUrl {
  return "https://USERNAME-mrgreat-ai.hf.space";
}
```

Ganti `USERNAME` dengan username HuggingFace kamu.

### 7. Build APK

```bash
flutter build apk --release
```

Install ke HP → **SELESAI! AI jalan 24/7!** 🎉

---

## Hasilnya
- ✅ AI jalan **24/7** — laptop boleh mati
- ✅ **WiFi manapun** bisa akses
- ✅ **Siapapun** bisa akses
- ✅ Tetap **Ollama Cloud + DeepSeek**
- ✅ **GRATIS tanpa credit card!**
- ✅ Tidak sleep/timeout

## Cek Status

Buka di browser: `https://USERNAME-mrgreat-ai.hf.space/api/health`

Kalau muncul `{"status": "ok"}` berarti server berjalan! ✅
