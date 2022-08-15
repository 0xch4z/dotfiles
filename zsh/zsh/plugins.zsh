mkdir -p "$ZSH_PLUGINS"

ensure_plugin() {
	repo="$1"
	git clone "$1" ~/$ZSH_PLUGINS/
}

ensure_plugin "https://github.com/kutsan/zsh-system-clipboard"

