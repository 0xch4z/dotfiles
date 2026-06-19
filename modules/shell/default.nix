{ den, ... }:
{
  den.aspects.shell.includes = [
    den.aspects.fish
    den.aspects.shell-path
    den.aspects.zsh
    den.aspects.tmux
    den.aspects.shell-utility
  ];
}
