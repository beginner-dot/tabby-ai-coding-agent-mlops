# 🤖 Tabby AI Coding Agent MLOps Deployment (CPU-Only, WSL2 + Ollama)

This project is a self-hosted AI coding agent platform built around **TabbyML** and **Ollama**, deployed on a resource-constrained **WSL2 CPU-only** environment. It documents how multiple architectures were designed, broken, and rebuilt until a stable, multi-model setup was achieved, serving as a real MLOps incident log.

The goal: run a local AI coding assistant with **code completion**, **chat**, and **embeddings** using only CPU power, with full troubleshooting notes.

---

## ✅ Final Architecture (Setup 3 – Native Binary + `config.toml`)

This stable architecture resolves the earlier Docker and CLI-only failures.

**Stack:**

- **TabbyML** native binary (v0.31.2) running inside WSL2 Ubuntu.
- **Ollama** serving three LLM models on a non-default port (`11435`).
- **Model roles (via Ollama):**
  - `llama3:8b` – Completion
  - `mistral:7b` – Chat
  - `nomic-embed-text` – Embeddings
- **Routing** explicitly controlled via a `config.toml` override file that forces Tabby to talk to the local Ollama API instead of an external registry.

**Example `config.toml` (simplified):**

--- Tabby AI Agent Configuration: Ollama Integration ---
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


> The `model_name` values must match the output of `ollama list` on your machine.

**Launch script (inside WSL2):**

#!/usr/bin/env bash

Launch Tabby in CPU-only mode on WSL2, using config.toml and a fixed host IP.
TABBY_HOST_IP="172.18.217.209" # Update if your WSL2 IP changes
TABBY_BIN="./tabby" # Update if your binary path differs
TABBY_CONFIG="./config.toml" # Path to the config file

sudo RUST_LOG=debug "${TABBY_BIN}" serve
--device cpu
--host "${TABBY_HOST_IP}"
--config "${TABBY_CONFIG}"


**Dashboard:**

- Accessible from the Windows host browser at:  
  `http://172.18.217.209:8080`

---

## 🧭 MLOps Journey: Three Architectures

### 1. Docker Container (Abandoned for Main Setup)

**Goal:** Run Tabby in a Docker container on WSL2 and reach it from Windows.

- Problem: Network bridge between the container and Windows host returned `Connection refused`.
- Result: HTTP access was unreliable from the host, even when the container was running.
- Decision: Drop Docker for the *primary* setup and move to a native binary to remove one unstable layer.

### 2. Native Binary with CLI `--model` Flags (Failed)

**Goal:** Run Tabby natively and wire it directly to Ollama models using CLI flags like `--model ollama/llama3:8b`.

- Problem: Tabby panicked (crashed) due to an external registry check, ignoring the local Ollama setup.
- Insight: Passing models only via CLI wasn’t enough; Tabby still tried to use its own registry logic.
- Decision: Move all model routing into `config.toml` so Tabby is forced to use the local Ollama API.

### 3. Native Binary + `config.toml` (Current Success)

**Goal:** Stable, repeatable CPU-only deployment with three roles (completion, chat, embeddings).

- Fixes:
  - Defined a `config.toml` that sets `api_endpoint = "http://localhost:11435"` for each model role.
  - Bound Tabby to the WSL2 VM IP (`172.18.217.209`) instead of `localhost` / `0.0.0.0`.
- Result:
  - Tabby service runs stably in WSL2.
  - The dashboard is reachable from Windows.
  - Ollama models run on CPU and are ready to serve completion/chat/embeddings.

---

## 🌐 Networking & Environment Highlights

**WSL2 networking issues encountered and solved:**

- `curl http://localhost:8080` and `curl http://0.0.0.0:8080` failed inside WSL2.
- Used `ip addr show eth0` to discover the WSL2 VM IP (e.g., `172.18.217.209`).
- Launched Tabby with `--host 172.18.217.209` and then accessed the dashboard from Windows via that IP and port.

**TCP vs HTTP debugging technique:**

- Used `curl` for HTTP-level checks.
- Used `nc -v 172.18.217.209 8080` (netcat) to confirm raw TCP connectivity when HTTP failed.
- This helped separate:
  - Pure network/firewall issues
  - From application-level / HTTP configuration problems.

**System hygiene & credentials:**

- Diagnosed and fixed a Windows/Microsoft Account credential problem that was interfering with WSL2 networking and security context.
- After cleaning corrupt credentials and re-signing into a stable account, cross-environment communication became more reliable.

---

## 📈 Current Status & Next Steps

**Current status:**

- Multiple **stable Tabby instances** exist:
  - One focused on completion.
  - One focused on embeddings.
  - Chat UI has been observed on the Tabby dashboard during experiments.
- Ollama is correctly configured for CPU-only use with:
  - `llama3:8b`
  - `mistral:7b`
  - `nomic-embed-text`
- Setup 3 (native + `config.toml`) is implemented and ready for full 3‑model verification.

**Planned next steps:**

- Finalize the complete 3‑model agent (completion + chat + embeddings in a single Tabby setup).
- Record a short demo (screen capture) showing:
  - Code completion,
  - Chat,
  - And, if possible, an embeddings-driven feature (e.g., search or context).

---

## 🛠 How to Use This Repo

This repository is meant to be:

- A **reference** for running Tabby + Ollama on CPU-only, WSL2-based systems.
- A **real-world troubleshooting log** of:
  - Docker networking issues,
  - WSL2 IP/host binding problems,
  - CLI vs config-file routing,
  - And environment/credential conflicts.
- A **starting point** for extending this setup to:
  - Kubernetes,
  - Cloud deployments (AWS/GCP/Azure),
  - Additional models and features.

**To reproduce the setup (high-level):**

1. Install WSL2 + Ubuntu on Windows.
2. Install **Ollama** in WSL2 and pull the required models:
   - `ollama pull llama3:8b`
   - `ollama pull mistral:7b`
   - `ollama pull nomic-embed-text`
3. Place `config.toml` and `launch_tabby.sh` in the same directory as your Tabby binary.
4. Make the script executable and run it:
   chmod +x launch_tabby.sh
   ./launch_tabby.sh



5. From Windows, open your browser at:  
`http://<your-wsl2-ip>:8080`  
(e.g., `http://172.18.217.209:8080`)

---
