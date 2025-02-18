# Stage for PyTorch + CUDA
FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04 AS base
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir torch \
    --index-url https://download.pytorch.org/whl/cu124 && \
    rm -rf /root/.cache/pip

# Stage to download Whisper
FROM base AS model_downloader
ENV WHISPER_MODEL_NAME=distil-large-v3
RUN pip3 install faster-whisper
RUN python3 -c "from faster_whisper.utils import download_model; download_model('$WHISPER_MODEL_NAME')"

# Application stage
FROM base AS app
WORKDIR /app

# Copy requirements and install other dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt && \
    rm -rf /root/.cache/pip

# Copy the model from the model_downloader stage
COPY --from=model_downloader /root/.cache/huggingface /root/.cache/huggingface

# Copy application source
COPY whisper_fastapi_online_server.py .
COPY src src

# Copy the entrypoint script
COPY docker-entrypoint.sh .
RUN chmod +x docker-entrypoint.sh && \
    sed -i 's/\r$//' docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]

# Expose the port
EXPOSE 8000