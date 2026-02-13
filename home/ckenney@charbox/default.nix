{ lib, self, pkgs, ... }: {
  imports = [
    ../../profiles/nixos

    self.outputs.modules
  ];

  x.role = "nix-workstation";

  x.home.editor.neovim.nightly = true;

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;

    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      terminal = "alacritty";
      drun-display-format = "{name}";
      disable-history = false;
      hide-scrollbar = true;
      display-drun = "Apps";
      display-run = "Run";
      display-window = "Windows";
      sidebar-mode = false;
    };

    theme = {
      "*" = {
        background-color = "transparent";
        text-color = "#ffffff";
        font = "JetBrains Mono 12";
      };

      window = {
        width = "40%";
        background-color = "rgba(0, 0, 0, 0.85)";
        border-radius = "15px";
        padding = "20px";
      };

      mainbox = { background-color = "transparent"; };

      inputbar = {
        background-color = "rgba(255, 255, 255, 0.1)";
        border-radius = "8px";
        padding = "10px";
        margin = "0px 0px 15px 0px";
      };

      prompt = {
        background-color = "transparent";
        text-color = "#ffffff";
      };

      entry = {
        background-color = "transparent";
        text-color = "#ff00ff";
        placeholder-color = "rgba(255, 0, 255, 0.6)";
      };

      listview = {
        lines = 10;
        background-color = "transparent";
        spacing = "3px";
      };

      element = {
        background-color = "transparent";
        padding = "8px";
        text-color = "#ffffff";
      };

      "element selected" = {
        background-color = "#ff00ff";
        border-radius = "5px";
        text-color = "#ffffff";
      };
    };
  };

  home.stateVersion = lib.mkForce "22.11";
  home.homeDirectory = "/home/ckenney";
}
