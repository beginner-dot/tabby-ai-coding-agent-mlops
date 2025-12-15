1. Paste this into your README.md
Open README.md in GitHub (click the pencil icon) and replace its contents with:

text
# Tabby AI Coding Agent MLOps (CPU-Only, WSL2 + Ollama)

This project is a self-hosted AI coding agent platform built around **TabbyML** and **Ollama**, deployed on a **WSL2 CPU-only** environment. It documents how multiple architectures were designed, broken, and rebuilt until a stable, multi-model setup was achieved.

The goal: run a local AI coding assistant with **code completion**, **chat**, and **embeddings** using only CPU, with full troubleshooting notes like a real MLOps incident log.

---

## Final Architecture (Setup 3 – Native + config.toml)

**Stack:**

- **TabbyML** native binary (v0.31.2) running inside WSL2 Ubuntu  
- **Ollama** serving three models on a non-default port (`11435`)  
  - `llama3:8b` – completion or chat role  
  - `mistral:7b` – completion or chat role  
  - `nomic-embed-text` – embeddings  
- **Routing** controlled via `config.toml`:

Example shape (simplified)
[server]
api_endpoint = "http://localhost:11435"

[models]

separate roles wired to Ollama models
completion_model = "ollama/llama3:8b"
chat_model = "ollama/mistral:7b"
embedding_model = "ollama/nomic-embed-text"
text

**Launch script (inside WSL2):**

sudo RUST_LOG=debug ./tabby serve
--device cpu
--host 172.18.217.209

text

**Dashboard:**

- Accessible from Windows browser at: `http://172.18.217.209:8080`

---

## MLOps Journey: Three Architectures

### 1. Docker Container (Abandoned)

- **Goal:** Run Tabby in a container on WSL2 and reach it from Windows.
- **Issue:** Network bridge between container and Windows host returned `Connection refused`.
- **Decision:** Drop Docker for the main setup and move to native binary to remove one unstable layer.

### 2. Native Binary with CLI `--model` Flags (Failed)

- **Goal:** Run Tabby natively and point it directly at Ollama models using `--model ollama/...`.
- **Issue:** Tabby crashed (panic) due to external registry checks and did not respect the local Ollama API as intended.
- **Decision:** Move model routing into `config.toml` instead of CLI flags.

### 3. Native Binary + `config.toml` (Current Success)

- **Goal:** Stable, repeatable CPU-only deployment with three roles: completion, chat, embeddings.
- **Fixes:**
  - Forced Tabby to use a config file with an explicit `api_endpoint` on `http://localhost:11435`.
  - Bound Tabby to the WSL2 VM IP (`172.18.217.209`) instead of `localhost` / `0.0.0.0`.
- **Result:** Stable Tabby dashboard reachable from Windows, with Ollama models running on CPU.

---

## Networking & Environment Highlights

- **WSL2 Networking:**
  - `curl http://localhost:8080` and `curl http://0.0.0.0:8080` failed inside WSL2.
  - Used `ip addr show eth0` to discover the WSL2 VM IP (e.g. `172.x.x.x`).
  - Bound Tabby to `--host 172.18.217.209` and confirmed reachability from Windows.

- **TCP vs HTTP Debugging:**
  - Used `curl` for HTTP tests.
  - Used `nc -v 172.18.217.209 8080` to confirm raw TCP connectivity when HTTP failed, separating network issues from application issues.

- **System Hygiene:**
  - Identified and fixed a Windows credential / Microsoft Account problem that interfered with WSL2 networking and security context.

---

## Current Status

- Multiple **stable Tabby instances** exist:
  - One focused on completion.
  - One focused on embeddings.
  - Chat UI has been observed working on the dashboard during experiments.
- Ollama is correctly configured for CPU-only use, with all three models pulled and running.
- The final architecture (Setup 3) is in place and ready for full 3‑model verification.

Planned next step:

- Finalize the complete 3‑model agent (completion + chat + embeddings in one Tabby setup) and record a short demo of real-time code assistance.

---

## How to Use This Repo

This repository is primarily:

- A **reference** for engineers running Tabby + Ollama on constrained (CPU-only, WSL2) environments.
- A **real-world troubleshooting log** of network, config, and environment issues encountered and solved during deployment.
- A **starting point** for extending the setup to Kubernetes, cloud deployments, or additional models.
