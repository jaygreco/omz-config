#!/bin/bash -ex

# Use this with 'curl -fsSL https://raw.githubusercontent.com/jaygreco/omz-config/main/install.sh | sh'

install_tailscale() {
    if [[ ! $(which tailscale) ]]; then
        curl -fsSL https://tailscale.com/install.sh | sh
        echo "Tailscale has been installed. Configure it with 'sudo tailscale up'."
    else
        echo "Tailscale is already installed"
    fi
}

configure_git() {
    GIT_EMAIL="jayv.greco@gmail.com"
    GIT_USER="Jay Greco"
    GIT_EDITOR="vi"
    if [[ -f ~/.gitconfig ]]; then
        # don't overwrite existing configuration
        if ! grep -q 'email' ~/.gitconfig; then 
            git config --global user.email "$GIT_EMAIL"
        fi
        if ! grep -q 'name' ~/.gitconfig; then 
            git config --global user.name "$GIT_USER"
        fi
        if ! grep -q 'editor' ~/.gitconfig; then 
            git config --global core.editor "$GIT_EDITOR"
        fi
    else
        git config --global user.email "$GIT_EMAIL"
        git config --global user.name "$GIT_USER"
        git config --global core.editor "$GIT_EDITOR"
    fi
}

# Check for zsh
if [[ ! $(which zsh) ]]; then
    echo "zsh is not installed! Do that first."
    exit 1
fi

# Install OMZ
if [[ ! -d ~/.oh-my-zsh ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Set ZSH_CUSTOM if not set
[[ -z $ZSH_CUSTOM ]] && ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Install OMZ plugins (check if already installed/present)
# Format: name;path
# A blank after ; indicates a built-in plugin
USE_ZSH_PLUGINS="git; \
fzf; \
autoupdate;https://github.com/TamCore/autoupdate-oh-my-zsh-plugins \
zsh-autosuggestions;https://github.com/zsh-users/zsh-autosuggestions \
zsh-syntax-highlighting;https://github.com/zsh-users/zsh-syntax-highlighting \
omz-config;https://github.com/jaygreco/omz-config \
"

plugins="plugins=("
for plugin in $USE_ZSH_PLUGINS; do
    # Split into plugin/path
    name="$(awk -F';' '{print $1}' <<< "$plugin")"
    path="$(awk -F';' '{print $2}' <<< "$plugin")"

    # Check if the plugin is already installed and is not built-in
    if [[ ! -d $ZSH_CUSTOM/plugins/$name && -n $path ]]; then
        git clone --depth 1 "$path"  "$ZSH_CUSTOM/plugins/$name"
    fi

    # Assemble the plugins directive
    plugins="$plugins $name"
done

# Update the plugins line in .zshrc
sed -i'.bak' "s/plugins=(.*/${plugins} )/g" ~/.zshrc && rm ~/.zshrc.bak

# Disable theme support so that PS1 and PROMPT settings stick
sed -i'.bak' "/^ZSH_THEME=/ s/./#&/" ~/.zshrc && rm ~/.zshrc.bak

# Install fzf (check)
if [[ ! $(which fzf) ]]; then
    FZF_PATH=~/.fzf
    [[ -d $FZF_PATH ]] && rm -rf $FZF_PATH
    git clone --depth 1 https://github.com/junegunn/fzf $FZF_PATH
    $FZF_PATH/install --key-bindings --completion --no-update-rc
fi
# Install tailscale (check)
echo "Do you want to install tailscale?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_tailscale; break;;
        No ) break;;
    esac
done

# Configure git (check)
echo "Do you want to configure git?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) configure_git; break;;
        No ) break;;
    esac
done

# Remind to source .zshrc
echo "Done! Close and reopen this shell, or 'source ~/.zshrc'."
