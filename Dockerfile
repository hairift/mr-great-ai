FROM python:3.11-slim

WORKDIR /app

# Copy server and data
COPY server/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY server/ ./
COPY data/ ../data/

# Expose port
EXPOSE 8000

# Start the server
CMD ["gunicorn", "main:app", "--workers", "2", "--worker-class", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000", "--timeout", "120"]
