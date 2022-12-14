fpath=($ASDF_DIR/completions $fpath)
fpath=($HOME/zsh/completions $fpath)

autoload -U +X bashcompinit && bashcompinit
autoload -Uz compinit && compinit
exists(){
  $1 -v &> /dev/null
}

if exists nerdctl.lima; then
    source <(nerdctl.lima completion zsh)
    compdef _nerdctl nerdctl.lima
fi

# make tab-completion work with aliases
setopt complete_aliases
setopt completealiases

complete -o nospace -C $(asdf which terraform) terraform
