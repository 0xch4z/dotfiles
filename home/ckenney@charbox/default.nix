{ lib, self, pkgs, ... }: {
  imports = [
    ../../profiles/nixos
    ../../roles/nixos

    self.outputs.modules
  ];

  x.home = {
    browser = {
      firefox.enable = true;
      zen.enable = true;
    };
    desktop.hyprland = {
      enable = true;
      hyprpaper.enable = true;
    };
    editor.neovim = {
      enable = true;
      nightly = true;
    };
    editor.vscode.enable = true;
    taskbar.waybar = {
      enable = true;
    };
  };

  home.stateVersion = lib.mkForce "22.11";
  home.homeDirectory = "/home/ckenney";
}
