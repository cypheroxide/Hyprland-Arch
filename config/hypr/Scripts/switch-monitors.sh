#!/bin/bash

# 💡 Set the directory where your monitor config files live.
# Adjust this path to match your Hyprland configuration structure.
CONFIG_DIR="$HOME/.config/hypr/UserConfigs"

# 🔄 Define the base name and the two setup names
BASE_CONF="04-monitors.conf"
INTERNAL_CONF="${BASE_CONF}.internal-only"
EXTERNAL_CONF="${BASE_CONF}.external-portrait"

# 🚩 Full paths for easier use
BASE_PATH="${CONFIG_DIR}/${BASE_CONF}"
INTERNAL_PATH="${CONFIG_DIR}/${INTERNAL_CONF}"
EXTERNAL_PATH="${CONFIG_DIR}/${EXTERNAL_CONF}"

# --- Script Start ---

echo "Starting Hyprland Monitor Config Switcher..."

if [ ! -d "$CONFIG_DIR" ]; then
    echo "🚨 Error: Configuration directory not found at $CONFIG_DIR"
    exit 1
fi

# 1. Check which configuration is currently active (i.e., named $BASE_CONF)

if [ -f "$BASE_PATH" ] && grep -q "transform" "$BASE_PATH"; then
    # Currently using the EXTERNAL (portrait) config
    echo "Currently active: External Portrait setup."
    echo "Switching to: Internal Only setup..."

    # a. Move active external config to its backup name
    mv "$BASE_PATH" "$EXTERNAL_PATH"

    # b. Move internal-only backup to the active name
    mv "$INTERNAL_PATH" "$BASE_PATH"

    echo "✅ Switched to Internal Only config."

elif [ -f "$BASE_PATH" ]; then
    # Assume it's the INTERNAL-ONLY config (does not contain 'transform' line/command)
    echo "Currently active: Internal Only setup."
    echo "Switching to: External Portrait setup..."

    # a. Move active internal config to its backup name
    mv "$BASE_PATH" "$INTERNAL_PATH"

    # b. Move external-portrait backup to the active name
    mv "$EXTERNAL_PATH" "$BASE_PATH"

    echo "✅ Switched to External Portrait config."

else
    # Handle the case where the active config file is missing
    echo "⚠️ Warning: $BASE_CONF not found. Checking for backups..."

    if [ -f "$INTERNAL_PATH" ]; then
        echo "Found Internal-Only backup. Activating it."
        mv "$INTERNAL_PATH" "$BASE_PATH"
        echo "✅ Activated Internal Only config."
    elif [ -f "$EXTERNAL_PATH" ]; then
        echo "Found External-Portrait backup. Activating it."
        mv "$EXTERNAL_PATH" "$BASE_PATH"
        echo "✅ Activated External Portrait config."
    else
        echo "🚨 Error: Neither active nor backup config files found. Aborting."
        exit 1
    fi
fi

# 2. Tell Hyprland to reload the monitor configuration
echo "Sending 'reload' command to Hyprland..."
hyprctl reload

echo "Script finished."
