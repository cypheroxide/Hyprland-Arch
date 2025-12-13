#!/usr/bin/env bash

# FZF Popup Search - Universal search launcher for Hyprland
# Searches files, directories, and applications with fuzzy finding

# Search modes
MODE="${1:-quick}"

# Config file for exclusions
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/Scripts/fzf-search.conf"

# Build exclusion list from config
EXCLUSIONS=()
if [[ -f "$CONFIG_FILE" ]]; then
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        EXCLUSIONS+=("$line")
    done < "$CONFIG_FILE"
fi

# FZF options
FZF_OPTS=(
    --height=100%
    --border=rounded
    --margin=1
    --padding=1
    --prompt='🔍 Search: '
    --color='bg+:#333333,bg:#000000,border:#ffd700,spinner:#ffd700,hl:#ffd700'
    --color='fg:#ffffff,header:#ffd700,info:#ffd700,pointer:#ffd700'
    --color='marker:#ffd700,fg+:#ffffff,prompt:#ffd700,hl+:#ffd700'
    --preview-window='right:50%:wrap'
    --bind='ctrl-/:change-preview-window(down|hidden|)'
    --bind='ctrl-space:toggle-preview'
    --ansi
)

case "$MODE" in
    files)
        # Search files in home directory
        FIND_CMD=(find "$HOME" -type f)
        
        # Add exclusions from config
        for excl in "${EXCLUSIONS[@]}"; do
            FIND_CMD+=(-not -path "*/${excl}/*" -not -path "*/${excl}")
        done
        
        SELECTED=$("${FIND_CMD[@]}" 2>/dev/null \
            | fzf "${FZF_OPTS[@]}" \
                --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {} 2>/dev/null || echo "Binary file"' \
                --preview-label='[ File Preview ]' \
                --header='Files Search - Enter to open')
        
        if [[ -n "$SELECTED" ]]; then
            xdg-open "$SELECTED" &
        fi
        ;;
    
    code)
        # Search in code directories
        FIND_CMD=(find "$HOME" -type f)
        
        # Add exclusions from config
        for excl in "${EXCLUSIONS[@]}"; do
            FIND_CMD+=(-not -path "*/${excl}/*" -not -path "*/${excl}")
        done
        
        SELECTED=$("${FIND_CMD[@]}" 2>/dev/null \
            | fzf "${FZF_OPTS[@]}" \
                --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}' \
                --preview-label='[ Code Preview ]' \
                --header='Code Search - Enter to open')
        
        if [[ -n "$SELECTED" ]]; then
            kitty --execute nvim "$SELECTED" &
        fi
        ;;
    
    apps)
        # Search desktop applications
        SELECTED=$(fd --type f . /usr/share/applications ~/.local/share/applications 2>/dev/null \
        | xargs -r grep -l "^Type=Application" \
        | while read -r desktop; do
            name=$(grep "^Name=" "$desktop" | head -1 | cut -d= -f2)
            comment=$(grep "^Comment=" "$desktop" | head -1 | cut -d= -f2)
            echo "$name|$desktop|$comment"
        done \
        | fzf "${FZF_OPTS[@]}" \
            --delimiter='|' \
            --with-nth=1,3 \
            --preview 'cat {2}' \
            --preview-label='[ Desktop Entry ]' \
            --header='Applications - Enter to launch')
        
        if [[ -n "$SELECTED" ]]; then
            DESKTOP_FILE=$(echo "$SELECTED" | cut -d'|' -f2)
            gtk-launch "$(basename "$DESKTOP_FILE")" &
        fi
        ;;
    
    process)
        # Search running processes
        ps aux --sort=-%mem \
        | fzf "${FZF_OPTS[@]}" \
            --header-lines=1 \
            --preview 'echo {}' \
            --preview-window=down:3:wrap \
            --preview-label='[ Process Details ]' \
            --header='Processes - Enter to show details'
        ;;
    
    quick|*)
        # Default: quick file search in common locations
        FIND_CMD=(find "$HOME/Documents" "$HOME/Downloads" -maxdepth 5 -type f)
        
        # Add exclusions from config
        for excl in "${EXCLUSIONS[@]}"; do
            FIND_CMD+=(-not -path "*/${excl}/*" -not -path "*/${excl}")
        done
        
        SELECTED=$("${FIND_CMD[@]}" 2>/dev/null \
            | fzf "${FZF_OPTS[@]}" \
                --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}' \
                --preview-label='[ Preview ]' \
                --header='Quick Search - Files in Documents/Downloads')
        
        if [[ -n "$SELECTED" ]]; then
            xdg-open "$SELECTED" &
        fi
        ;;
esac
