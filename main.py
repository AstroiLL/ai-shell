#!/usr/bin/env python3
"""ai-shell — Python stub (the real work is in bin/ai).

This exists so `uv run ai` works from within the project dir.
For terminal use, `bin/ai` is the canonical entry point.
"""

import subprocess
import sys


def main() -> None:
    """Delegate to the bash script."""
    script = __file__.rsplit("/", 2)[0] + "/bin/ai"
    subprocess.run([script, *sys.argv[1:]])


if __name__ == "__main__":
    main()
