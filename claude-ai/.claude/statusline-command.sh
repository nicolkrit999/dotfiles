#!/usr/bin/env bash
# Claude Code status line — mirrors Starship Nord/base16 theme
# Colors: purple=#b48ead, cyan=#88c0d0, green=#a3be8c, yellow=#ebcb8b, red=#bf616a, reset

input=$(cat)

user=$(whoami)
host=$(hostname -s)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten cwd: replace $HOME with ~, then truncate to last 3 segments
if [ -n "$cwd" ]; then
    cwd="${cwd/#$HOME/\~}"
    # Truncate to last 3 path components with ellipsis prefix
    seg_count=$(echo "$cwd" | tr '/' '\n' | grep -c '.')
    if [ "$seg_count" -gt 3 ]; then
        cwd="…/$(echo "$cwd" | rev | cut -d'/' -f1-3 | rev)"
    fi
fi

# Build context indicator
ctx_part=""
if [ -n "$used" ] && [ "$used" != "null" ]; then
    used_int=${used%.*}
    if [ "$used_int" -ge 80 ]; then
        ctx_color="\033[38;2;191;97;106m"   # red
    elif [ "$used_int" -ge 50 ]; then
        ctx_color="\033[38;2;235;203;139m"  # yellow
    else
        ctx_color="\033[38;2;163;190;140m"  # green
    fi
    ctx_part=" ${ctx_color}ctx:${used_int}%\033[0m"
fi

# Build model part
model_part=""
if [ -n "$model" ]; then
    model_part=" \033[38;2;136;192;208m${model}\033[0m"
fi

printf "\033[1;38;2;180;142;173m%s@%s\033[0m \033[38;2;129;161;193m%s\033[0m%s%s\n" \
    "$user" "$host" "$cwd" "$model_part" "$ctx_part"
