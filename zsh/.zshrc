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

[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"


autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /Users/char/.asdf/installs/terraform/1.2.7/bin/terraform terraform
