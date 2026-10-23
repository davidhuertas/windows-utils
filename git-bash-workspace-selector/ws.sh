#!/usr/bin/env bash
# ws.sh — interactive workspace chooser (pure bash)
# Usage: source ws.sh  (or: . ws.sh)
# Optional: export WORKSPACES_FILE=~/.workspaces

set -uo pipefail

# ---- Configure workspaces here (name|path) ----
# Auto-detect .workspaces file if not specified
if [[ -z "${WORKSPACES_FILE:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [[ -f "$SCRIPT_DIR/.workspaces" ]]; then
    WORKSPACES_FILE="$SCRIPT_DIR/.workspaces"
  fi
fi

# Or load from file if present (each line: Name|/full/path)
if [[ -n "${WORKSPACES_FILE:-}" && -f "${WORKSPACES_FILE}" ]]; then
  mapfile -t WORKSPACES < "${WORKSPACES_FILE}"
else
  # Hardcoded fallback if no file specified
  WORKSPACES=(
    "INGCDaaS|$HOME/Developer/INGCDaaS"
    "IngEurCDaaS01|$HOME/Developer/IngEurCDaaS01"
    "OneJOP Project|$HOME/Developer/one-jop-project"
    "Misc|$HOME/Developer/zz_misc"
  )
fi

if ((${#WORKSPACES[@]} == 0)); then
  echo "No workspaces configured."
  (return 1 2>/dev/null) || exit 1
fi

# Extract names + paths
names=()
paths=()
for item in "${WORKSPACES[@]}"; do
  # Remove any trailing whitespace/carriage returns from the line
  item="${item%$'\r'}"
  item="${item%$'\n'}"
  
  name="${item%%|*}"
  path="${item#*|}"
  
  # Trim whitespace from path
  path="${path#"${path%%[![:space:]]*}"}"
  path="${path%"${path##*[![:space:]]}"}"
  
  # Remove trailing slash if present
  path="${path%/}"
  
  names+=( "$name" )
  paths+=( "$path" )
done

# ---- UI helpers ----
esc="$(printf '\033')"
cursor_hide(){ printf '%s[?25l' "$esc"; }
cursor_show(){ printf '%s[?25h' "$esc"; }
clear_lines(){ local n="$1"; for ((i=0;i<n;i++)); do printf '\r%s[2K%s[1A' "$esc" "$esc"; done; printf '\r%s[2K' "$esc"; }

# ---- Color helpers ----
color_reset="${esc}[0m"
color_selected="${esc}[1;97;44m"   # Bold bright white on blue background
color_unselected="${esc}[92m"      # Bright green
color_path="${esc}[95m"            # Bright magenta
color_title="${esc}[1;93m"         # Bold bright yellow
color_hint="${esc}[1;96m"          # Bold bright cyan

render_menu() {
  local selected="$1"
  echo -e "${color_title}Select your workspace:${color_reset}"
  for i in "${!names[@]}"; do
    if [[ "$i" -eq "$selected" ]]; then
      printf "  %s%s%s${color_reset}\n" "$color_selected" "${names[$i]}" "$color_reset"
      printf "     ${color_path}%s${color_reset}\n" "${paths[$i]}"
    else
      printf "    ${color_unselected}%s${color_reset}\n" "${names[$i]}"
    fi
  done
  echo ""
  echo -e "${color_hint}Use ↑/↓ arrows and Enter to select. Press 'q' to quit or 'e' to export.${color_reset}"
}
export_workspaces() {
  local out_file="$1"
  if ! { for i in "${!names[@]}"; do
           echo "${names[$i]}|${paths[$i]}"
         done > "$out_file"; } 2>/dev/null; then
    echo "ERROR: could not write to $out_file" >&2
    return 1
  fi
  echo "Exported workspaces to $out_file"
}


# ---- Interactive loop ----
selected=0
lines_to_clear=$(( ${#names[@]} + 4 ))

cursor_hide
# NOTE: this script is sourced, and ws-launch.sh exec's over it afterwards, so
# an EXIT trap would fire far too late (or never). Every exit path below must
# call cursor_show itself, and the traps are removed before we return.
trap 'cursor_show; echo; trap - INT TERM; return 130 2>/dev/null || exit 130' INT TERM

render_menu "$selected"

while true; do
  IFS= read -rsn1 key || true

  # Arrow keys are escape sequences: ESC [ A/B
  if [[ "$key" == "$esc" ]]; then
    read -rsn2 key2 || true
    case "$key2" in
      "[A") # up
        ((selected--))
        if ((selected < 0)); then selected=$((${#names[@]} - 1)); fi
        ;;
      "[B") # down
        ((selected++))
        if ((selected >= ${#names[@]})); then selected=0; fi
        ;;
    esac
  elif [[ "$key" == "" ]]; then
    # Enter
    break
  elif [[ "$key" == "q" || "$key" == "Q" ]]; then
    cursor_show
    trap - INT TERM
    echo
    (return 0 2>/dev/null) || exit 0
  elif [[ "$key" == "e" || "$key" == "E" ]]; then
    # Export workspaces. Count the lines we print instead of hardcoding the
    # redraw offset, so adding or removing a prompt cannot smear the menu.
    cursor_show
    extra_lines=0
    echo ""; extra_lines=$((extra_lines + 1))
    printf 'Export to file: '
    IFS= read -r out_file || out_file=""
    extra_lines=$((extra_lines + 1))   # the newline echoed when the user pressed Enter
    if [[ -n "$out_file" ]]; then
      export_workspaces "$out_file"
    else
      echo "Export cancelled."
    fi
    extra_lines=$((extra_lines + 1))
    printf 'Press any key to continue...'
    read -rsn1 _
    echo   # leave the cursor on a fresh line so the count below is exact
    extra_lines=$((extra_lines + 1))
    # Clear only our own prompt lines; the loop tail below clears and redraws
    # the menu itself.
    clear_lines "$extra_lines"
    cursor_hide
  fi

  clear_lines "$lines_to_clear"
  render_menu "$selected"
done

cursor_show
trap - INT TERM

chosen_path="${paths[$selected]}"
echo
echo "→ Switching to: ${names[$selected]}  ($chosen_path)"

if [[ -d "$chosen_path" ]]; then
  cd "$chosen_path" || true
  export WS_CHOSEN_PATH="$chosen_path"
else
  echo "ERROR: Path does not exist: $chosen_path" >&2
fi
