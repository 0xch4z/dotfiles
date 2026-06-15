{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (config.x.profile.workstation && pkgs.stdenv.hostPlatform.isLinux) {
    home = {
      sessionPath = [
        "$HOME/.local/bin"
        "/usr/local/bin"
        "/opt/homebrew/bin"
      ];

      sessionVariables = {
        EDITOR = "nvim";
        PAGER = "less";
        TERMINAL = "alacritty";
      };
    };

    x.home = {
      desktop = {
        enable = lib.mkDefault true;
        backend = lib.mkDefault "hyprland";
      };

      taskbar.ashell.enable = lib.mkDefault true;
    };
  };
}
