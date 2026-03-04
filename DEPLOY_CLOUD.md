# Deploy Mr. Great AI ke Cloud (GRATIS, 24/7)

Server AI akan jalan SELAMANYA di cloud — laptop boleh mati, WiFi manapun bisa akses.

## Langkah-langkah

### 1. Push ke GitHub

```bash
cd C:\Users\riana\mr_great_ai
git init
git add .
git commit -m "Mr. Great AI"
git remote add origin https://github.com/USERNAME/mr-great-ai.git
git push -u origin main
```

### 2. Deploy ke Render.com (GRATIS)

1. Buka: https://render.com → daftar pakai GitHub (gratis)
2. Klik **"New" → "Web Service"**
3. Pilih repository `mr-great-ai`
4. Setting:
   - **Name**: `mrgreat-ai`
   - **Region**: Singapore
   - **Instance Type**: **Free**
5. Klik **"Environment"** → tambahkan variable:

| Key | Value |
|-----|-------|
| `AI_PROVIDER` | `ollama_cloud` |
| `OLLAMA_CLOUD_API_KEY` | `a2f97ef2effa4c5fbc99f3374aeb35b3.LlcoRRIcf4rFaBbVsaFR4DPI` |
| `OLLAMA_CLOUD_BASE_URL` | `https://api.ollama.com` |
| `OLLAMA_CLOUD_MODEL` | `deepseek-v3.1:671b-cloud` |
| `API_KEY` | `mrgreat-ucic-2024-secret-key` |

6. Klik **"Deploy"** → tunggu sampai selesai (~5 menit)

### 3. Update Flutter App

Setelah deploy, Render kasih URL seperti: `https://mrgreat-ai.onrender.com`

Edit `lib/api_config.dart`:
```dart
static String get baseUrl {
  return "https://mrgreat-ai.onrender.com";
}
```

### 4. Build APK

```bash
flutter build apk --release
```

Install ke HP → **SELESAI! AI jalan 24/7!**

---

## Catatan Penting

- **Free tier Render**: Server "tidur" setelah 15 menit tidak dipakai. Request pertama setelah tidur butuh ~30 detik.
- **Upgrade** ke Render paid ($7/bulan) supaya server selalu aktif tanpa delay.
- Untuk hapus deployment: login ke Render dashboard → delete service.
