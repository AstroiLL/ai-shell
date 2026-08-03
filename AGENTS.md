# ai-shell

AI Shell — Hermes-powered CLI for quick AI queries, pipes, and Telegram delivery.

## Core Philosophy

Do NOT reimplement an LLM client. This project is a thin shell wrapper around
the already-installed Hermes Agent. Hermes already has:
- DeepSeek API keys
- Gateway (Telegram integration)
- All tools (web search, file read, terminal, etc.)

## Key commands

- `hermes -z "prompt"` — one-shot, prints ONLY response text (pipe-friendly)
- `hermes send --to telegram "msg"` — send to Telegram
- `hermes chat -q "prompt" -Q` — quiet interactive chat

## Project layout

```
ai-shell/
├── bin/ai          # Main shell script
├── README.md       # User-facing docs
├── pyproject.toml  # uv project metadata
└── AGENTS.md       # This file
```

## Script conventions

- Bash, `set -euo pipefail`
- Thin wrapper — all real work delegated to `hermes` CLI
- stdin pipe support: `[[ ! -t 0 ]]` to detect piped input
- Options before positional args, standard `getopts`-style `while` loop
