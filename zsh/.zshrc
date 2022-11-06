source "$HOME/zsh/init.zsh"
source "$HOME/zsh/env.zsh"
source "$HOME/zsh/path.zsh"
source "$HOME/zsh/zim.zsh"
source "$HOME/zsh/completion.zsh"
source "$HOME/zsh/aliases.zsh"
source "$HOME/zsh/functions.zsh"
source "$HOME/zsh/keybinds.zsh"

# vim mode
bindkey -v

# hook for local overrides
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
