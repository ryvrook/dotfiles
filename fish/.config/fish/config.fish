set -g fish_greeting

alias ls "eza --icons"
alias ll "eza -l --icons --git"
alias la "eza -la --icons --git"
alias lt "eza --tree --level=2 --icons"
alias cat bat
alias g git
alias cls clear
alias cd.. "cd .."
alias rebuild "$HOME/dotfiles/rebuild"

abbr -a .. "cd .."
abbr -a ... "cd ../.."

set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --exclude .git"
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -gx FZF_ALT_C_COMMAND "fd --type d --hidden --exclude .git"

starship init fish | source
zoxide init fish | source
fzf --fish | source
direnv hook fish | source

# yazi wrapper: cd to the dir you quit in
function y
    set tmp (mktemp -t yazi-cwd.XXXXXX)
    yazi $argv --cwd-file="$tmp"
    if read -z cwd < "$tmp"; and test -n "$cwd"; and test "$cwd" != "$PWD"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end
