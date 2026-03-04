FROM python:3.11-slim

WORKDIR /app

# Copy server and data
COPY server/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY server/ ./
COPY data/ ../data/

# HF Spaces uses port 7860 by default
ENV PORT=7860
EXPOSE 7860

# Start the server (uses PORT from env)
CMD gunicorn main:app --workers 2 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:${PORT} --timeout 120
