# This file holds aliases, and other common zsh configuration.
# It sources from ~/.zshoverrides, which can be used for adding site-specific aliases and preferences.

# Shared aliases
alias dirsize="sudo du -h . --max-depth=1"
alias clear="echo 'nope'"

del-knownhost() {
    sed -i'.bak' -e "$1d" ~/.ssh/known_hosts
    rm ~/.ssh/known_hosts.bak
}

alert() {
    # Capture command
    CMD="$*"
    START=$SECONDS
    
    eval "$CMD"

    # Capture return value
    STATUS="$?"
    T=$((SECONDS-START))
    >&2 echo "$CMD: $STATUS in $T s"

    # Print a warning message if the webhook URL doesn't exist
    if [[ -z "$ALERT_WEBOOK_URL" ]]; then
        >&2 echo "WARN: ALERT_WEBOOK_URL is missing. No message will be sent."
    else
        # Capture success/fail
        if [[ $STATUS -eq 0 ]]; then
            RES="✅"
        else 
            RES="❌"
        fi

        # Generate message
        MSG="has finished in $T sec with exit code:"

        # Format message properly for each service
        case "$ALERT_WEBOOK_URL" in 
            *"discord"*) JSON="{\"content\":\"$RES \`$CMD\` $MSG \`$STATUS\`\"}";;
            *"slack"*) JSON="{\"message\":\"$MSG\", \"cmd\":\"$CMD\", \"result\":\"$RES\", \"exit_code\":\"$STATUS\"}";;
        esac

        curl -d "$JSON" -H "Content-Type: application/json" -X POST $ALERT_WEBOOK_URL
    fi
}

# Prompt config
PROMPT='%(?.%F{green}➜.%F{red}%? ➜)%f [%~$(git_prompt_info)] $program %#%{$fg[default]%} '

ZSH_THEME_GIT_PROMPT_PREFIX=":%{$fg[blue]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# Set autoupdate frequency
export UPDATE_ZSH_DAYS=1
export DISABLE_UPDATE_PROMPT=true

if [[ $(uname) == "Darwin" ]]; then
    # Aliases for MacOS only
    export PATH="/opt/homebrew/bin:$PATH"
    export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"

    alias sublime="subl"

    brew-packages() {
        brew list | xargs brew info | egrep --color '\d*\.\d*(KB|MB|GB)'
    }
else
    # Linux only aliases
    alias open="code -g"
fi

# Source .zshoverrides if it exists
[ -f ~/.zshoverrides ] && source ~/.zshoverrides
