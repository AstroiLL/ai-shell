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
├── bin/ai          # Main script (Python, canonical entry point)
├── main.py         # Python stub for `uv run ai`
├── pyproject.toml  # uv project metadata
├── README.md       # User-facing docs
├── INSTALL.md      # Setup & install
├── DEVELOPER.md    # Dev guide: architecture, adding modes
└── AGENTS.md       # This file
```

## Script conventions

- Python 3.12+ (stdlib only, no external deps), shebang `#!/usr/bin/env python3`
- Thin wrapper — all real work delegated to `hermes` CLI
- stdin pipe support: `not sys.stdin.isatty()` detects piped input
- Options via `argparse` with custom parser that suggests similar args on typos
- `-1..-9` shorthand maps to `--verbose` (verbosity level)
