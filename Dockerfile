# Stage for PyTorch and heavy dependencies
FROM python:3.12-slim AS pytorch_base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Install PyTorch first for better layer caching
RUN pip install torch --index-url https://download.pytorch.org/whl/cu124

# Application stage
FROM pytorch_base
WORKDIR /app

# Copy requirements and install other dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

RUN python -c "from faster_whisper.utils import download_model; download_model('large-v3-turbo')"

# Copy application source
COPY whisper_fastapi_online_server.py .
COPY src src

# Command to run the server
CMD ["python", "whisper_fastapi_online_server.py", "--host", "0.0.0.0", "--port", "8000", "--model", "large-v3-turbo", "--language", "auto"]

# Expose the port
EXPOSE 8000