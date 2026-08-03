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
- `hermes sessions rename <id> <title>` — rename a session

## Project layout

```
ai-shell/
├── bin/ai          # ★ Single-file Python CLI (canonical entry point)
├── main.py         # Python stub so `uv run ai` works from the project dir
├── pyproject.toml  # uv project metadata
├── README.md       # User-facing docs
├── INSTALL.md      # Setup guide
├── DEVELOPER.md    # Dev guide: adding modes, conventions
└── AGENTS.md       # This file
```

## Script conventions

- **Python 3.12+, stdlib only** — no external dependencies
- Thin wrapper — all real work delegated to `hermes` CLI
- stdin pipe support: `not sys.stdin.isatty()` detects piped input
- `argparse` with smart typo suggestions (`AIArgumentParser` + `smart_suggest_arg`)
- Modes: `general` / `shell` / `explain` / `code`, driven by `PROMPTS` dict + `MODE_MAP`
- Verbose levels 1–9 via `-v N` or `-N` shorthand (`ai -5 "..."`)
- stdout = answer only (pipe-friendly); stderr = diagnostics/status
- `--send` sends the RAW (unstyled, no ANSI) response to Telegram
- Session auto-rename: queries the local `~/.hermes/state.db` for the last CLI
  session and renames it to `ai: <clean title>`
