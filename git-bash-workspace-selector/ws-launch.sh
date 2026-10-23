#!/usr/bin/env bash
# ws-launch.sh — Launch Git Bash with workspace selector

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run workspace selector (auto-detects .workspaces in same directory)
source "$SCRIPT_DIR/ws.sh"

# Belt and braces: exec replaces this process, so nothing in ws.sh can clean up
# after this point. Make sure the terminal cursor is visible first.
printf '\033[?25h'

# Keep bash open
exec /usr/bin/bash -i
