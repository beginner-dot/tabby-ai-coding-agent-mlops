#!/usr/bin/env bash

# --- Tabby AI Agent Launch Script ---
# Environment: WSL2 (CPU-Only)
# Integration: Local Ollama (port 11435)

# 1. Variables
TABBY_HOST_IP="172.18.217.209" # Update if your WSL2 IP changes
TABBY_BIN="./tabby"            # Update if your binary path differs
TABBY_CONFIG="./config.toml"   # Path to the config file

# 2. Safety Check
if [[ ! -f "$TABBY_CONFIG" ]]; then
    echo "❌ Error: config.toml not found! Please create it before launching."
    exit 1
fi

echo "🚀 Launching Tabby AI on http://${TABBY_HOST_IP}:8080"
echo "📡 Connecting to Ollama on http://localhost:11435"

# 3. Execution
# --device cpu is mandatory for systems without a dedicated GPU.
sudo RUST_LOG=info "${TABBY_BIN}" serve \
  --device cpu \
  --host "${TABBY_HOST_IP}" \
  --config "${TABBY_CONFIG}"
