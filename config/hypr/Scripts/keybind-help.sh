#!/usr/bin/env bash
set -euo pipefail

# Keybind help menu - displays key bindings in a readable format
# Uses fuzzel for consistent theming with power menu

# Define keybinds with descriptions
keybinds="🖥️  Window Management
Super + T                    Open terminal (kitty)
Super + Q                    Kill active window
Super + M                    Exit Hyprland
Super + F                    Toggle floating
Super + P                    Toggle pseudotile
Super + J                    Toggle split (dwindle)
Super + ←/→/↑/↓              Move focus
Super + 1-9,0                Switch to workspace 1-10
Super + Shift + 1-9,0        Move window to workspace 1-10

📱  Applications
Super + Space                Application launcher (wofi)
Super + R                    Application launcher (rofi)
Super + S                    FZF Popup Search (files/code)
Super + /                    Keybind help (this menu)
Super + B                    Launch Brave browser
Super + Control + V          Launch VSCodium - Wayland
Super + O                    Launch OBS
Super + E                    File manager in terminal (Yazi)
Super + V                    Clipboard history
XF86Caclulator               Launch Calculator (floating)

🔒  System Control
Super + L                    Lock screen (hyprlock)
Super + F12                  Dropdown terminal
Super + Shift + Esc          System monitor (btop)
Super + ALT + Space          Update app-menu (native/flat/appimage)
Super + CTRL + M             Toggle Monitor Config
CTRL + Shift + Enter         Terminal New Pane
CTRL + Shift + T             Terminal New Tab

📸  Screenshots
Print                        Screenshot output/monitor
Super + Print                Screenshot window
Super + Shift + S            Screenshot region

🎵  Media & Volume
XF86AudioRaiseVolume         Volume up
XF86AudioLowerVolume         Volume down
XF86AudioMute                Toggle mute
XF86AudioMicMute             Toggle mic mute
XF86AudioNext                Next track
XF86AudioPrev                Previous track
XF86AudioPlay/Pause          Play/pause

💡  Display
XF86MonBrightnessUp          Brightness up
XF86MonBrightnessDown        Brightness down

🖱️  Mouse
Super + LMB drag             Move window
Super + RMB drag             Resize window
Super + scroll               Switch workspaces"

# Show fuzzel menu with golden theme matching power menu
echo "$keybinds" | fuzzel --dmenu \
    --prompt='Keybinds ' \
    --lines=30 \
    --width=65 \
    --background-color='000000cc' \
    --text-color='ffd700ff' \
    --selection-color='333333cc' \
    --selection-text-color='ffd700ff' \
    --border-color='ffd70080' \
    --border-width=2 \
    --font='DejaVu Sans Mono:size=12' \
    --match-mode=exact
