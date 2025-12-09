#!/usr/bin/env bash

# Simple test - just search recent files
fd --type f --max-depth 3 . "$HOME/Code" "$HOME/Downloads" 2>/dev/null \
    | fzf \
        --height=100% \
        --border=rounded \
        --prompt='Search: ' \
        --color='bg:#000000,border:#ffd700' \
        --preview 'cat {}' \
        --preview-window='right:50%'
