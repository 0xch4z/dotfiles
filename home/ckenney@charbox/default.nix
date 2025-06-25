{ lib, self, pkgs, ... }: {
  imports = [
    ../../profiles/nixos
    ../../roles/nixos

    self.outputs.modules
  ];

  home.sessionVariables = {
    QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.qt6.qtbase}/lib/qt-6/plugins/platforms";
    QT_PLUGIN_PATH = "${pkgs.qt6.qtbase}/lib/qt-6/plugins";
  };

  home.packages = with pkgs; [
    qt6.qtwayland
    libsForQt5.qt5.qtwayland
  ];

  x.home.desktop = {
    enable = true;
    backend = "hyprland";
  };

  x.home.editor.neovim.nightly = true;

  x.home = {
    browser = {
      firefox.enable = true;
      zen.enable = true;
    };
    taskbar.waybar = {
      enable = true;
    };
  };


  home.stateVersion = lib.mkForce "22.11";
  home.homeDirectory = "/home/ckenney";
}
