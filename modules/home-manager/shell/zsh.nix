{ config, ... }:
{
  programs.zsh = {
    enable = true;
    profileExtra = ''
      if [ -d "/etc/profiles/per-user/${config.home.username}/bin" ]; then
        path=(/etc/profiles/per-user/${config.home.username}/bin $path)
      fi
    '';
  };
}
