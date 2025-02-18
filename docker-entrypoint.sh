#!/bin/bash
set -e

# Default values for environment variables
: "${WHISPER_MODEL_NAME:=distil-large-v3}"
: "${HOST:=0.0.0.0}"
: "${PORT:=8000}"
: "${LANGUAGE:=en}"
: "${MIN_CHUNK_SIZE:=1}"

CMD="python3 whisper_fastapi_online_server.py \
    --host $HOST \
    --port $PORT \
    --model $WHISPER_MODEL_NAME \
    --language $LANGUAGE \
    --min-chunk-size $MIN_CHUNK_SIZE"

# Execute the command
exec $CMD