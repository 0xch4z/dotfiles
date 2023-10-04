export -f zsrc() {
   (cd $HOME && source .zshrc)
}

export -f secaddpw() {
    local name="$1"
    local value="$2"
    security add-generic-password -a "$USER" -s "$name" -w "$value"
}

export -f secgetpw() {
    local name="$1"
    security find-generic-password -a "$USER" -s "$name" -w
}
