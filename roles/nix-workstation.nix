{lib, ...}: {
  imports = [
    ./workstation.nix
  ];

  home = {
    stateVersion = "22.11";

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

    taskbar.waybar.enable = lib.mkDefault true;
  };
}
