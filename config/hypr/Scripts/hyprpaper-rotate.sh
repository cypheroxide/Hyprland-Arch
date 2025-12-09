#!/usr/bin/env bash
set -euo pipefail

CONFIG="$HOME/.config/hypr/hyprpaper.conf"

# Collect preloaded wallpapers from config (ignore commented/empty)
mapfile -t WALLS < <(grep -E '^[[:space:]]*preload[[:space:]]*=' "$CONFIG" | sed -E 's/^[[:space:]]*preload[[:space:]]*=[[:space:]]*//; s/[[:space:]]+$//')

if [ ${#WALLS[@]} -eq 0 ]; then
  echo "No preloaded wallpapers found in $CONFIG" >&2
  exit 1
fi

# Help hyprctl find the Hyprland instance when run via systemd user
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}"
if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && [ -d "$XDG_RUNTIME_DIR/hypr" ]; then
  export HYPRLAND_INSTANCE_SIGNATURE="$(ls -1 "$XDG_RUNTIME_DIR/hypr" | head -n1 || true)"
fi

# Pick a random preloaded wallpaper
RANDOM_WALL="$(printf '%s\n' "${WALLS[@]}" | shuf -n 1)"

# Get monitor names (handle JSON or plain)
if command -v jq >/dev/null 2>&1; then
  mapfile -t MONITORS < <(hyprctl monitors -j | jq -r '.[].name')
else
  mapfile -t MONITORS < <(hyprctl monitors | awk '/Monitor/{print $2}')
fi

# Fallback to eDP-1 if detection fails (single-monitor case from context)
if [ ${#MONITORS[@]} -eq 0 ]; then
  MONITORS=(eDP-1)
fi

# Wait for hyprpaper to be ready; then set wallpaper on each monitor
for MON in "${MONITORS[@]}"; do
  success=0
  for i in {1..30}; do
    if hyprctl hyprpaper wallpaper "$MON,$RANDOM_WALL" >/dev/null 2>&1; then
      success=1
      break
    fi
    sleep 0.5
  done
  if [ "$success" -ne 1 ]; then
    echo "Failed to set wallpaper on $MON (is hyprpaper running and preloads loaded?)" >&2
  fi
done

echo "Set wallpaper to: $RANDOM_WALL on monitors: ${MONITORS[*]}"