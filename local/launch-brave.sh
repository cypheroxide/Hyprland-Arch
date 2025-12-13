#!/bin/bash
export WAYLAND_DISPLAY=wayland-1
# Disable KWallet to avoid timeout delays
export DISABLE_KWALLET=1
# Use basic password storage instead of KWallet
export CHROME_PASSWORD_STORE=basic
exec brave --new-window --password-store=basic
