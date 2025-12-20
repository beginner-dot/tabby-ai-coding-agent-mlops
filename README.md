# 🤖 Tabby AI Coding Agent MLOps Deployment (CPU-Only, WSL2 + Ollama)

This project is a self-hosted AI coding agent platform built around **TabbyML** and **Ollama**, deployed on a resource-constrained **WSL2 CPU-only** environment. It documents how multiple architectures were designed, broken, and rebuilt until a stable, multi-model setup was achieved, serving as a real MLOps incident log.

The goal: run a local AI coding assistant with **code completion**, **chat**, and **embeddings** using only CPU power, with full troubleshooting notes.

---

## ✅ Final Architecture (Setup 3 – Native Binary + `config.toml`)

This stable architecture resolves the earlier Docker and CLI-only failures.

**Stack:**
- **TabbyML:** Native binary (v0.31.2) running inside WSL2 Ubuntu.
- **Ollama:** Serving three LLM models on a non-default port (`11435`).
- **Model roles (via Ollama):**
  - `llama3:8b` – Completion
  - `mistral:7b` – Chat
  - `nomic-embed-text` – Embeddings



### ⚙️ Example `config.toml` (Setup 3 Solution)
This configuration file explicitly routes each AI role to the correct local Ollama API endpoint.

```toml
# --- Tabby AI Agent Configuration: Ollama Integration ---

[model.completion.http]
kind = "ollama/completion"
model_name = "llama3:8b"
api_endpoint = "http://localhost:11435"

[model.chat.http]
kind = "ollama/chat"
model_name = "mistral:7b"
api_endpoint = "http://localhost:11435"

[model.embedding.http]
kind = "ollama/embedding"
model_name = "nomic-embed-text"
api_endpoint = "http://localhost:11435"
Note: The model_name values must match the output of ollama list on your machine exactly.

🚀 Launch Script (inside WSL2)
Create a file named launch_tabby.sh with the following content:

Bash

#!/usr/bin/env bash

# Launch Tabby in CPU-only mode on WSL2, using config.toml and a fixed host IP.
TABBY_HOST_IP="172.18.217.209" # Update if your WSL2 IP changes
TABBY_BIN="./tabby"            # Update if your binary path differs
TABBY_CONFIG="./config.toml"   # Path to the config file

sudo RUST_LOG=debug "${TABBY_BIN}" serve \
  --device cpu \
  --host "${TABBY_HOST_IP}" \
  --config "${TABBY_CONFIG}"
Dashboard: Accessible from the Windows host browser at: http://172.18.217.209:8080

🧭 MLOps Journey: Three Architectures
1. Docker Container (Abandoned)
Goal: Run Tabby in a Docker container on WSL2.

Problem: Network bridge between the container and Windows host returned Connection refused.

Decision: Dropped Docker for the primary setup to remove an unstable networking layer.

2. Native Binary with CLI Flags (Failed)
Goal: Point Tabby at Ollama using CLI flags (--model ollama/llama3:8b).

Problem: Tabby panicked (crashed) due to an external registry check, ignoring the local Ollama setup.

Decision: Moved model routing into config.toml to force local API priority.

3. Native Binary + config.toml (Success)
Fixes: Defined explicit api_endpoint for each role and bound Tabby to the WSL2 VM IP instead of localhost.

Result: Stable service reachable from Windows with 3-model support on CPU.

🌐 Networking & Environment Highlights
WSL2 Binding: Discovered that localhost binding inside WSL2 often fails for external host access. Used ip addr show eth0 to find the fixed VM IP (172.18.217.209).

Diagnostic Stack:

Used curl for HTTP-level health checks.

Used nc -v 172.18.217.209 8080 (netcat) to confirm raw TCP connectivity.

Credential Hygiene: Resolved a Windows credential conflict that was restricting WSL2 socket permissions.

🛠 How to Use This Repo
Install WSL2 + Ubuntu on Windows.

Install Ollama and pull models:

Bash

ollama pull llama3:8b
ollama pull mistral:7b
ollama pull nomic-embed-text
Configure: Place config.toml and launch_tabby.sh in your Tabby directory.

Execute:

Bash

chmod +x launch_tabby.sh
./launch_tabby.sh
Verify: Open http://172.18.217.209:8080 in your Windows browser.
Verify: Open http://172.18.217.209:8080 in your Windows browser.


---
