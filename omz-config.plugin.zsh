# This file holds aliases, and other common zsh configuration.
# It sources from ~/.zshoverrides, which can be used for adding site-specific aliases and preferences.

# Shared aliases
alias dirsize="sudo du -h . --max-depth=1"
alias clear="echo 'nope'"

del-knownhost() {
    sed -i"bak -e "$1d" ~/.ssh/known_hosts"
    rm ~/.ssh/known_hosts.bak
}

# Prompt config
export PROMPT="%(?.%F{green}➜.%F{red}%? ➜)%f [%~] $program %#%{$fg[default]%} "
export PS1="$PROMPT"

if [[ $(uname) == "Darwin" ]]; then
    # Aliases for MacOS only
    alias sublime="subl"
    alias brew-packages="brew list | xargs brew info | egrep --color '\d*\.\d*(KB|MB|GB)'"

    export PATH="/opt/homebrew/bin:$PATH"
    export PATH="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin:$PATH"
else
    # Linux only aliases
    alias open="code -g"
fi

# Source .zshoverrides if it exists
[ -f ~/.zshoverrides ] && source ~/.zshoverrides
