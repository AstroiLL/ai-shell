#compdef ai

# ai completion for zsh
# Source: source completions/ai.zsh
# Install: cp completions/ai.zsh /usr/local/share/zsh/site-functions/_ai

_ai_chat_names() {
    local chats_file="$HOME/.config/ai-shell/chats.json"
    local -a names
    if [[ -f "$chats_file" ]]; then
        names=(${(f)"$(python3 -c "
import json
try:
    chats = json.load(open('$chats_file'))
    for name in chats:
        print(name)
except: pass
" 2>/dev/null)"})
    fi
    compadd "$@" -a names
}

_ai() {
    local state

    _arguments -s \
        '-s[Shell mode: generate a command]' \
        '--shell[Shell mode: generate a command]' \
        '-e[Explain mode: explain output/error from stdin]' \
        '--explain[Explain mode: explain output/error from stdin]' \
        '--code[Code mode: generate code]' \
        '-c[Copy response to clipboard]' \
        '--copy[Copy response to clipboard]' \
        '-m[Model name]:model:' \
        '--model[Model name]:model:' \
        '-p[Provider name]:provider:' \
        '--provider[Provider name]:provider:' \
        '--send[Send result to Telegram]:target:' \
        '-r[Run generated shell command]' \
        '--run[Run generated shell command]' \
        '--no-color[Disable colored output]' \
        '-v[Verbosity level 1-9]:level:(1 2 3 4 5 6 7 8 9)' \
        '--verbose[Verbosity level 1-9]:level:(1 2 3 4 5 6 7 8 9)' \
        '-V[Show version]' \
        '--version[Show version]' \
        '--fix-sessions[Fix old CLI session titles]' \
        '--chat[Chat mode: interactive dialog with context]' \
        '-n[Chat session name]:name:->chat_names' \
        '--name[Chat session name]:name:->chat_names' \
        '-l[List saved chats]' \
        '--list-chats[List saved chats]' \
        '-d[Delete chat from registry]:name:->chat_names' \
        '--delete-chat[Delete chat from registry]:name:->chat_names' \
        '-h[Show help]' \
        '--help[Show help]' \
        && return 0

    case "$state" in
        chat_names)
            _ai_chat_names
            ;;
    esac
}

_ai "$@"
