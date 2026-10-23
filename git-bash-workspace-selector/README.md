# Git Bash Workspace Selector

Interactive TUI that asks which workspace to open when a Git Bash window starts, then `cd`s there and exports `WS_CHOSEN_PATH`.

Install, configuration, and Windows Terminal setup are documented in the [repo README](../README.md#git-bash-workspace-selector).

## Files

| File               | Role                                                                                             |
| ------------------ | ------------------------------------------------------------------------------------------------ |
| `ws.sh`            | The selector. Must be **sourced**, not executed — it changes the caller's directory.             |
| `ws-launch.sh`     | Shortcut/profile wrapper: sources `ws.sh`, then `exec /usr/bin/bash -i` to keep the window open. |
| `bash.exe.lnk`     | Shortcut to `/Git/bin/bash.exe` with `ws-launch.sh` at start, to map in Windows Terminal         |
| `git-bash.exe.lnk` | Shortcut to `/Git/git-bash.exe` with `ws-launch.sh` at start, to run under MINGW64               |
| `.workspaces`      | Machine-local workspace list, `Name\|/c/path` per line. Ships empty.                             |
