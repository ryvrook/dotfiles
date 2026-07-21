# Interactive-only
[[ $- != *i* ]] && return

HISTCONTROL=ignoredups:ignorespace
HISTSIZE=10000
HISTFILESIZE=100000

alias ls='eza --icons'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --level=2 --icons'
alias cat='bat'
alias g='git'
alias ..='cd ..'
alias ...='cd ../..'
alias rebuild="$HOME/dotfiles/rebuild"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'

eval "$(starship init bash)"
eval "$(zoxide init bash)"
eval "$(fzf --bash)"
eval "$(direnv hook bash)"

# yazi wrapper: cd to the dir you quit in
y() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
