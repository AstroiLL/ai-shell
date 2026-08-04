# ai completion for bash
# Source this file: source completions/ai.bash
# Or install: cp completions/ai.bash /etc/bash_completion.d/ai

_ai_completion() {
    local cur prev words cword
    _init_completion || return

    # All flags
    local opts="-s --shell -e --explain --code -c --copy -m --model -p --provider
                --send -r --run --no-color -v --verbose -V --version
                --fix-sessions --chat -n --name -l --list-chats -d --delete-chat -h --help"

    # Modes that take an argument
    local arg_opts="-m --model -p --provider -n --name -d --delete-chat -v --verbose"

    # Handle --chat -n NAME: suggest saved chat names
    if [[ "$prev" == "-n" || "$prev" == "--name" ]]; then
        local chats_file="$HOME/.config/ai-shell/chats.json"
        if [[ -f "$chats_file" ]]; then
            local names=$(python3 -c "import json; print(' '.join(json.load(open('$chats_file'))))" 2>/dev/null)
            COMPREPLY=($(compgen -W "$names" -- "$cur"))
        fi
        return 0
    fi

    # Handle --delete-chat: suggest chat names
    if [[ "$prev" == "-d" || "$prev" == "--delete-chat" ]]; then
        local chats_file="$HOME/.config/ai-shell/chats.json"
        if [[ -f "$chats_file" ]]; then
            local names=$(python3 -c "import json; print(' '.join(json.load(open('$chats_file'))))" 2>/dev/null)
            COMPREPLY=($(compgen -W "$names" -- "$cur"))
        fi
        return 0
    fi

    # Handle flags that take values
    for opt in $arg_opts; do
        if [[ "$prev" == "$opt" ]]; then
            COMPREPLY=()
            return 0
        fi
    done

    # Default: suggest flags
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "$opts" -- "$cur"))
        return 0
    fi

    # After all flags: suggest nothing (free-form query)
    COMPREPLY=()
}

complete -F _ai_completion ai
