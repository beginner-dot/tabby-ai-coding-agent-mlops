# 🤖 Tabby AI Coding Agent MLOps Deployment (CPU-Only, WSL2 + Ollama)

This project is a self-hosted AI coding agent platform built around **TabbyML** and **Ollama**, deployed on a resource-constrained **WSL2 CPU-only** environment. It documents how multiple architectures were designed, broken, and rebuilt until a stable, multi-model setup was achieved, serving as a real MLOps incident log.

The goal: run a local AI coding assistant with **code completion**, **chat**, and **embeddings** using only CPU power, with full troubleshooting notes.

---

## ✅ Final Architecture (Setup 3 – Native Binary + `config.toml`)

This stable architecture resolves the earlier Docker and CLI-only failures by bypassing external registry checks and forcing local routing.

**Stack:**
- **TabbyML:** Native binary (v0.31.2) running inside WSL2 Ubuntu.
- **Ollama:** Serving three LLM models on a non-default port (`11435`).
- **Model Roles (via Ollama):**
  - `llama3:8b` – Completion
  - `mistral:7b` – Chat
  - `nomic-embed-text` – Embeddings

### ⚙️ Final `config.toml` (Setup 3 Solution)
This configuration file is the "brain" of the setup. It explicitly routes each AI role to the correct local Ollama API endpoint.

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
