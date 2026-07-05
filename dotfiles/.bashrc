#!/bin/bash
[[ $- != *i* ]] && return

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    startx
else
    tmux a
    tmux
    clear
fi

PS1='\W$ '

export GPG_TTY=$(tty)
export VISUAL=nvim
export EDITOR="$VISUAL"
export GOPATH="$HOME/.go"
export PATH="$GOPATH/bin:$PATH"

alias keys=' eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519
  ssh-add ~/.ssh/git'

alias ls='lsd --color=auto'
alias vim='nvim'
alias copy="xclip -selection clipboard"
alias grep='grep --color=auto'
alias wifi='nmcli device wifi'
alias dotfiles='git -C /home/jonasz/workflow'
alias gitignore='cp ~/.config/scripts/ignoretemplate .gitignore'
alias codexinstall='npm i -g @openai/codex'
alias docker-desktop="/opt/docker-desktop/bin/docker-desktop > /dev/null 2>&1 &"

function fcd() {
    local find
    find=$(find "$HOME" -type d,f | fzf)
    if [ "$find" = "" ] || [ "$find" = "." ]; then
        return
    fi
    if [ -d "$find" ]; then
        cd "$find" || return
    else
        local dir
        dir=$(dirname "$find")
        cd "$dir" || return
        name=$(basename "$find")
        vim "$name"
    fi
}

function dfupdate() {
    git -C /home/jonasz/workflow add -u
    git -C /home/jonasz/workflow commit -m "update"
    git -C /home/jonasz/workflow push
}

export PATH=$PATH:$HOME/.go/bin
export HISTCONTROL=ignoreboth
export HISTTIMEFORMAT="%d/%m/%y %T    $"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:/home/jonasz/go/bin
export PATH=$PATH:/usr/bin/go

# Claude Code: Ctrl+G opens nvim with last reply in a split (claude-editor wrapper)
alias claude='VISUAL="$HOME/.local/bin/claude-editor" EDITOR="$HOME/.local/bin/claude-editor" claude'
