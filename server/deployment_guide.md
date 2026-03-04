# Mr. Great AI Server — Production Deployment Guide

## Architecture Overview

```
Mobile App (Flutter)
     │ HTTPS
     ▼
Nginx (Reverse Proxy + SSL)
     │ HTTP localhost:8000
     ▼
FastAPI Backend (Uvicorn + Gunicorn)
     │ HTTP localhost:11434
     ▼
Ollama (LLM Engine)
     │
     ▼
Model: deepseek-v3.1:671b-cloud
```

## Prerequisites

- Ubuntu 22.04+ VPS (DigitalOcean, AWS, GCP, etc.)
- Minimum: 4GB RAM, 2 vCPU, 30GB storage
- Recommended: 8GB+ RAM with GPU for faster inference
- Domain name pointing to your VPS IP

---

## Step 1: Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y python3 python3-pip python3-venv git curl nginx certbot python3-certbot-nginx ufw
```

## Step 2: Install Ollama

```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Pull the model (this may take a while)
ollama pull llama3

# Or pull your preferred model:
# ollama pull deepseek-v3.1:671b-cloud

# Verify Ollama is running
curl http://localhost:11434/api/tags
```

### Make Ollama a systemd service:
```bash
sudo tee /etc/systemd/system/ollama.service > /dev/null <<EOF
[Unit]
Description=Ollama LLM Server
After=network-online.target

[Service]
Type=simple
User=$USER
Environment="OLLAMA_HOST=127.0.0.1:11434"
ExecStart=/usr/local/bin/ollama serve
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl start ollama
```

## Step 3: Deploy Backend

```bash
# Clone your project
cd /opt
sudo mkdir mr_great_ai && sudo chown $USER:$USER mr_great_ai
git clone <your-repo-url> mr_great_ai
cd mr_great_ai/server

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
pip install gunicorn

# Configure environment
cp .env .env.production
nano .env.production
```

### Production .env file:
```env
OLLAMA_BASE_URL=http://127.0.0.1:11434
OLLAMA_MODEL=llama3
HOST=0.0.0.0
PORT=8000
RAG_TOP_K=3
MAX_TOKENS=500
API_KEY=YOUR_STRONG_API_KEY_HERE
RATE_LIMIT_PER_MINUTE=30
MAX_INPUT_LENGTH=2000
```

> ⚠️ **IMPORTANT**: Change `API_KEY` to a strong, unique key!
> Generate one with: `python3 -c "import secrets; print(secrets.token_urlsafe(32))"`

### Create systemd service:
```bash
sudo tee /etc/systemd/system/mrgreat-api.service > /dev/null <<EOF
[Unit]
Description=Mr. Great AI API Server
After=network.target ollama.service
Wants=ollama.service

[Service]
Type=simple
User=$USER
WorkingDirectory=/opt/mr_great_ai/server
Environment="PATH=/opt/mr_great_ai/server/venv/bin"
EnvironmentFile=/opt/mr_great_ai/server/.env.production
ExecStart=/opt/mr_great_ai/server/venv/bin/gunicorn main:app \
    --workers 4 \
    --worker-class uvicorn.workers.UvicornWorker \
    --bind 127.0.0.1:8000 \
    --timeout 120 \
    --access-logfile /opt/mr_great_ai/server/access.log \
    --error-logfile /opt/mr_great_ai/server/error.log
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable mrgreat-api
sudo systemctl start mrgreat-api

# Verify
sudo systemctl status mrgreat-api
curl http://localhost:8000/api/health
```

## Step 4: Setup Nginx

```bash
# Copy the provided nginx config
sudo cp /opt/mr_great_ai/server/nginx.conf /etc/nginx/sites-available/mrgreat
sudo ln -s /etc/nginx/sites-available/mrgreat /etc/nginx/sites-enabled/

# Edit: replace YOUR_DOMAIN with your actual domain
sudo nano /etc/nginx/sites-available/mrgreat

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

## Step 5: SSL with Let's Encrypt (FREE)

```bash
# Get SSL certificate
sudo certbot --nginx -d your-domain.com

# Auto-renew (certbot sets this up automatically)
sudo certbot renew --dry-run
```

## Step 6: Firewall (UFW)

```bash
# Enable UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# Verify — only 22, 80, 443 should be open
sudo ufw status
```

## Step 7: Flutter App Configuration

Update `lib/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = "https://your-domain.com";
  static const String apiKey = "YOUR_STRONG_API_KEY_HERE";
  // ... rest stays the same
}
```

---

## Monitoring & Logs

```bash
# View API logs
tail -f /opt/mr_great_ai/server/server.log
tail -f /opt/mr_great_ai/server/access.log

# View Ollama logs
journalctl -u ollama -f

# View service status
sudo systemctl status mrgreat-api
sudo systemctl status ollama
sudo systemctl status nginx
```

---

## Scaling

### Vertical Scaling
- Add more RAM/CPU to handle more concurrent users
- Add GPU for significantly faster inference (NVIDIA recommended)

### Horizontal Scaling
- Deploy multiple instances behind a load balancer (Nginx upstream)
- Use Redis for shared rate limiting across instances

### Docker Deployment
```bash
# Build and run with Docker Compose
docker compose up -d
```

Example `docker-compose.yml`:
```yaml
version: '3.8'
services:
  ollama:
    image: ollama/ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama

  api:
    build: ./server
    ports:
      - "8000:8000"
    env_file: ./server/.env.production
    depends_on:
      - ollama

volumes:
  ollama_data:
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Ollama not responding | `sudo systemctl restart ollama` |
| API returning 500 | Check `server.log` and `error.log` |
| SSL expired | `sudo certbot renew` |
| Out of memory | Increase swap: `sudo fallocate -l 4G /swapfile` |
| Model too slow | Use a smaller model like `llama3` or add GPU |
