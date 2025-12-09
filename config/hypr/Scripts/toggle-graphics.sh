#!/usr/bin/env bash
set -euo pipefail

# Dual UKI Graphics Mode Toggle Script for Discordia
# Switches between AMD iGPU-only and NVIDIA hybrid graphics modes
# Uses efibootmgr to change boot order

INTEGRATED_BOOT_ID="0001"
HYBRID_BOOT_ID="0006"

notify() {
  local msg="$1"
  # Hyprland native overlay notify
  if command -v hyprctl &>/dev/null; then
    hyprctl notify 0 5000 "rgb(8cc2ff)" "$msg" &>/dev/null || true
  fi
  # Desktop notification (dunst/mako)
  if command -v notify-send &>/dev/null; then
    notify-send "Graphics Toggle" "$msg"
  fi
  printf '%s\n' "$msg"
}

get_current_mode() {
  local boot_order
  boot_order=$(efibootmgr 2>/dev/null | grep "^BootOrder:" | awk '{print $2}')
  local first_boot
  first_boot=$(echo "$boot_order" | cut -d',' -f1)
  
  case "$first_boot" in
    "$INTEGRATED_BOOT_ID") echo "integrated" ;;
    "$HYBRID_BOOT_ID") echo "hybrid" ;;
    *) echo "unknown" ;;
  esac
}

get_mode_description() {
  local mode="$1"
  case "$mode" in
    integrated) echo "AMD iGPU only (Battery-saving mode)" ;;
    hybrid) echo "AMD + NVIDIA dGPU (Performance mode)" ;;
    *) echo "Unknown mode" ;;
  esac
}

verify_boot_entries() {
  local entries
  entries=$(efibootmgr 2>/dev/null)
  
  if ! echo "$entries" | grep -q "^Boot${INTEGRATED_BOOT_ID}"; then
    notify "ERROR: Integrated boot entry (Boot${INTEGRATED_BOOT_ID}) not found!"
    return 1
  fi
  
  if ! echo "$entries" | grep -q "^Boot${HYBRID_BOOT_ID}"; then
    notify "ERROR: Hybrid boot entry (Boot${HYBRID_BOOT_ID}) not found!"
    return 1
  fi
  
  return 0
}

switch_to_integrated() {
  notify "Switching to Integrated mode (AMD iGPU only)..."
  sudo efibootmgr -o "${INTEGRATED_BOOT_ID},${HYBRID_BOOT_ID},2001,2002,2003" >/dev/null
  notify "✓ Boot order updated. Reboot to activate Integrated mode."
}

switch_to_hybrid() {
  notify "Switching to Hybrid mode (NVIDIA enabled)..."
  sudo efibootmgr -o "${HYBRID_BOOT_ID},${INTEGRATED_BOOT_ID},2001,2002,2003" >/dev/null
  notify "✓ Boot order updated. Reboot to activate Hybrid mode."
}

show_status() {
  local current_mode
  current_mode=$(get_current_mode)
  local mode_desc
  mode_desc=$(get_mode_description "$current_mode")
  
  printf "\n=== Graphics Mode Status ===\n"
  printf "Current Mode: %s\n" "$current_mode"
  printf "Description: %s\n" "$mode_desc"
  printf "\nBoot Entries:\n"
  efibootmgr 2>/dev/null | grep -E "BootOrder|Boot${INTEGRATED_BOOT_ID}|Boot${HYBRID_BOOT_ID}"
  printf "\n"
}

toggle_mode() {
  local current_mode
  current_mode=$(get_current_mode)
  
  case "$current_mode" in
    integrated)
      switch_to_hybrid
      ;;
    hybrid)
      switch_to_integrated
      ;;
    *)
      notify "ERROR: Unable to determine current mode"
      return 1
      ;;
  esac
}

main() {
  # Verify boot entries exist
  if ! verify_boot_entries; then
    exit 1
  fi
  
  local action="${1:-toggle}"
  
  case "$action" in
    integrated|iGPU|amd)
      switch_to_integrated
      ;;
    hybrid|dGPU|nvidia)
      switch_to_hybrid
      ;;
    status|show)
      show_status
      ;;
    toggle)
      toggle_mode
      ;;
    *)
      printf "Usage: %s {integrated|hybrid|status|toggle}\n" "$0"
      printf "\nModes:\n"
      printf "  integrated - AMD iGPU only (battery-saving)\n"
      printf "  hybrid     - AMD + NVIDIA dGPU (performance)\n"
      printf "  status     - Show current mode\n"
      printf "  toggle     - Switch between modes (default)\n"
      exit 1
      ;;
  esac
}

main "$@"
