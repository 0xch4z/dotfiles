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

    programs.fuzzel = {
      enable = lib.mkDefault true;
      package = lib.mkDefault (config.x.home.graphics.wrapPackage pkgs.fuzzel);
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
