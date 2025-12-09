#!/usr/bin/env bash
set -euo pipefail

# Yazi Keybind Help Menu - displays key bindings in fuzzel
# Matches the golden/yellow theme from Hyprland keybind helper

KEYMAP="${XDG_CONFIG_HOME:-$HOME/.config}/yazi/keymap.toml"

# Separator line
sep() { printf '%s\n' "────────────────────────────────────────────────────────"; }

# Extract custom keybinds from keymap.toml
collect_custom() {
    [ -f "$KEYMAP" ] || return 0
    
    # Parse TOML keybind entries with desc field
    awk '
        BEGIN { in_keymap = 0; on = ""; desc = ""; run = "" }
        /^\[\[.*prepend_keymap\]\]/ { in_keymap = 1; on = ""; desc = ""; run = ""; next }
        in_keymap && /^on\s*=/ {
            match($0, /on\s*=\s*(.*)/, a)
            on = a[1]
            gsub(/[\[\]"]/, "", on)
            gsub(/,\s*/, " + ", on)
        }
        in_keymap && /^desc\s*=/ {
            match($0, /desc\s*=\s*"([^"]*)"/, d)
            desc = d[1]
        }
        in_keymap && /^run\s*=/ {
            match($0, /run\s*=\s*"([^"]*)"/, r)
            run = r[1]
        }
        in_keymap && /^$/ {
            if (on != "" && desc != "") {
                printf "  %-22s %s\n", on, desc
            }
            in_keymap = 0
        }
        END {
            if (on != "" && desc != "") {
                printf "  %-22s %s\n", on, desc
            }
        }
    ' "$KEYMAP"
}

# Build keybind content
navigation="📂 Navigation
  j / k              Move down / up
  h / l              Parent dir / Enter dir
  g g / G            Jump to top / bottom
  H / L              Back / Forward in history
  ~                  Go to home directory
  /                  Go to root
  .                  Toggle hidden files
  s                  Sort menu
  z                  Jump to directory (via zoxide)"

file_ops="📝 File Operations
  y                  Yank (copy) files
  d                  Cut files
  p                  Paste files
  x                  Delete files
  a                  Create new file/dir
  r                  Rename file
  R                  Reload directory
  o                  Open with...
  Enter              Open file / Enter directory"

selection="✓ Selection
  Space              Toggle selection
  v                  Visual mode
  V                  Visual mode (inverse)
  Ctrl+a             Select all
  Ctrl+r             Inverse selection
  Esc                Clear selection"

search_tabs="🔍 Search & Tabs
  /                  Search/filter files
  n / N              Next / Previous match
  Esc                Clear search
  t                  New tab
  Tab / Shift+Tab    Next / Previous tab
  1-9                Switch to tab 1-9
  Ctrl+w             Close current tab"

shell_help="⌨️  Shell & Tasks
  :                  Command mode
  !                  Shell command in cwd
  w                  Show tasks
  ?                  Help menu"

plugins="🔌 Plugins (Custom Keybinds)"

# Collect custom keybinds
custom=$(collect_custom || true)

# Build complete content
content=$(cat <<EOF
$navigation
$(sep)
$file_ops
$(sep)
$selection
$(sep)
$search_tabs
$(sep)
$shell_help
$(sep)
$plugins
$custom
EOF
)

# Display via fuzzel with Tokyo Night + golden accent theme
echo "$content" | fuzzel --dmenu \
    --prompt="Yazi Keybinds  " \
    --font="JetBrainsMono Nerd Font:size=11" \
    --lines=32 \
    --width=70 \
    --background="1a1b26ee" \
    --text-color="c0caf5ff" \
    --prompt-color="e0af68ff" \
    --selection-color="292e42ff" \
    --selection-text-color="e0af68ff" \
    --match-color="7aa2f7ff" \
    --border-color="e0af68ff" \
    --border-width=2 \
    --border-radius=8 \
    --horizontal-pad=16 \
    --vertical-pad=8 \
    --inner-pad=6
