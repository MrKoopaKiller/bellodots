if status is-interactive
    # Commands to run in interactive sessions can go here
end
# Disable greetings message
set fish_greeting #
# Enable brew
eval (/opt/homebrew/bin/brew shellenv)

# Functions for emulating bash !! and !$ commands
function bind_bang
    switch (commandline -t)[-1]
        case "!"
            commandline -t -- $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end
function bind_dollar
    switch (commandline -t)[-1]
        case "!"
            commandline -f backward-delete-char history-token-search-backward
        case "*"
            commandline -i '$'
    end
end
function fish_user_key_bindings
    bind ! bind_bang
    bind '$' bind_dollar
end

# Aliases
alias del='trash'
alias docker_clean_images='docker rmi $(docker images -a --filter=dangling=true -q)'
alias docker_clean_ps='docker rm $(docker ps --filter=status=exited --filter=status=created -q)'
alias ga="git add"
alias gb="git checkout -b"
alias gc="git clone"
alias gci="git commit"
alias gco="git checkout"
alias gp="git pull"
alias gpp="git push -u"
alias gs="git status"
alias j="autojump"
alias k="kubectl"
alias kaf="kubectl apply -f"
alias kd="kubectl describe"
alias kdel="kubectl delete"
alias kg="kubectl get"
alias kl="kubectl logs"
alias ll='eza -Flh --git -a'
alias ls='eza'
alias lst='eza -T --level 1'
alias mk="minikube"
alias rm='echo -ne "Use \"del\" instead."'
alias tf="terraform"
alias tg="terragrunt"
alias vi="nvim"
alias vim="nvim"

## Apps custom settings

# autojump
[ -f /opt/homebrew/share/autojump/autojump.fish ]; source /opt/homebrew/share/autojump/autojump.fish