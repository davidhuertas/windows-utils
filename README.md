# windows-utils

A small monorepo of standalone developer utilities for Windows 11. Each utility lives in its own directory, has no dependencies on the others, and is installed by hand — there is no build step, package manager, or shared runtime.

## Utilities

| Directory | What it does | Status |
|---|---|---|
| [`git-bash-workspace-selector/`](git-bash-workspace-selector/) | Interactive TUI that asks which workspace to open when a Git Bash window starts, then `cd`s there. | Done |
| [`jdk-path-selector/`](jdk-path-selector/) | Pick an active JDK per shell. | WIP: migrate to ps1, build jdk selector instead of having several scripts, docs |

## Requirements

- Windows 11
- [Git for Windows](https://gitforwindows.org/) (provides Git Bash / MSYS bash 4+)
- Optional: Windows Terminal, for the multi-pane startup layout
- Optional(?): More than one JDK

## jdk-path-selector

This scripts are so old that are in `.bat` format. For now you can just:

- edit the ones with the version you have and replace the path to your JDKs
- open a cmd console as Administrator
- run `cd /path/to/your/windows-utils/jdk-path-selector/; javaX.bat`;

## git-bash-workspace-selector

### Quick try

Open Git Bash in this repo and run:

```bash
source git-bash-workspace-selector/ws.sh
```

It must be **sourced**, not executed. The script's purpose is to change directory and export `WS_CHOSEN_PATH` in your current shell; running it as `./ws.sh` does that inside a subshell that immediately exits.

Controls: `↑`/`↓` to move, `Enter` to select, `q` to quit, `e` to export the current list to a file.

### Configure your workspaces

Create or edit `git-bash-workspace-selector/.workspaces`, one entry per line:

```
INGCDaaS|/c/Users/you/Developer/INGCDaaS
OneJOP Project|/c/Users/you/Developer/one-jop-project
Misc|/c/Users/you/Developer/zz_misc
```

Rules:

- Format is `Name|Path`. The name may contain spaces.
- The path must be MSYS-style (`/c/Users/...`), not `C:\Users\...` — `cd` runs inside Git Bash.
- The file that ships in this repo is intentionally empty; it is your machine-local list.

The list is resolved in this order:

1. `$WORKSPACES_FILE`, if set
2. `.workspaces` sitting next to `ws.sh`, if it exists
3. A hardcoded fallback array inside `ws.sh`

Note that an existing but empty `.workspaces` still wins over the fallback, and the script will report `No workspaces configured.` Delete the file or fill it in.

To point at a list elsewhere:

```bash
export WORKSPACES_FILE=~/.workspaces
source git-bash-workspace-selector/ws.sh
```

### Install as a Git Bash shortcut

Create a Git Bash shortcut, open its properties, and set the target to:

```
"C:/Program Files/Git/git-bash.exe" -c "source /c/path/to/windows-utils/git-bash-workspace-selector/ws-launch.sh"
```

Set "Start in" to:

```
C:/Program Files/Git
```

Pin the shortcut anywhere — taskbar, Start menu, desktop. `ws-launch.sh` sources the selector and then hands you an interactive shell in the chosen directory.

### Windows Terminal Configuration

When adding or modifying Git Bash profile, use the `bash.exe` binary instead, and include the source in the commandLine property:

`C:\\Program Files\\Git\\bin\\bash.exe -c \"source /c/path/to/windows-utils/git-bash-workspace-selector/ws-launch.sh\"`

### Windows Terminal layout

To open three Git Bash panes (one wide on the right, two stacked on the left), each running the selector, add to your Windows Terminal settings:

```json
{
  "startupActions": "new-tab -p \"Git Bash\" -c \"source C:\\path\\to\\windows-utils\\git-bash-workspace-selector\\ws-launch.sh\" ; split-pane -V -p \"Git Bash\" -c \"source C:\\path\\to\\windows-utils\\git-bash-workspace-selector\\ws-launch.sh\" ; move-focus first ; split-pane -H -p \"Git Bash\" -c \"source C:\\path\\to\\windows-utils\\git-bash-workspace-selector\\ws-launch.sh\" ; move-focus previous"
}
```

Replace `C:\path\to` with wherever you cloned this repo.

## Layout

```
windows-utils/
├── git-bash-workspace-selector/
│   ├── ws.sh              # sourceable selector engine
│   ├── ws-launch.sh       # shortcut wrapper: source ws.sh, then exec bash -i
│   ├── .workspaces        # your machine-local workspace list
│   └── README.md          # install notes
├── jdk-path-selector/     # placeholder
└── CLAUDE.md              # notes for Claude Code
```

## Contributing a new utility

Add a directory at the repo root with the tool and its own README. Keep it self-contained — no cross-utility imports, no root-level build.
