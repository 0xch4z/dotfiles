# my dotfiles

> "you are your dotfiles" -Tony Soprano

## Setup

### Macos

```
# install nix
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon

# add initial config
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

# install nix-darwin
nix run github:LnL7/nix-darwin#darwin-installer
```

[stow]: https://www.gnu.org/software/stow/
