{
  self,
  pkgs,
  ...
}:
let
  inherit (self.lib.lists) map range;

  g8 = "desc:Samsung Electric Company Odyssey G80SD H1AK500000";
in
{
  imports = [
    ../../profiles/nixos
  ];

  x.profile.workstation = true;
  x.profile.personal = true;

  x.home.editor.neovim.nightly = false;
  x.home.taskbar.ashell.nvidiaEnvironment.enable = true;

  x.home.applications.browser.chromium = {
    ozonePlatform = "x11";
    nvidiaWorkarounds.enable = true;
  };

  x.home.desktop.hyprland = {
    # Was using IDs (e.g. HDMI-A-1), but those are non-deterministic when the
    # AMD iGPU and NVIDIA dGPU load in different orders. Match the primary
    # monitor by description and keep these desktop-only rules off laptops.
    wallpaperMonitor = g8;
    monitorProfiles.g8-only.outputs = [
      {
        search = "s=H1AK500000";
        mode = "3840x2160@119.88Hz";
        position = "0,0";
        scale = 1.0;
        workspaces = map (n: n) (range 1 9);
      }
    ];
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "FiraCode Nerd Font:size=12";
        terminal = "alacritty";
        icons-enabled = "yes";
        icon-theme = "hicolor";
        lines = 10;
        width = 40;
        horizontal-pad = 20;
        vertical-pad = 15;
        layer = "overlay";
        anchor = "top";
        y-margin = 8;
      };
      colors = {
        background = "000000dd";
        text = "ffffffff";
        match = "ff69b4ff";
        selection = "ff00ffff";
        selection-text = "ffffffff";
        selection-match = "ffffffdd";
        border = "ff69b480";
      };
      border = {
        width = 2;
        radius = 12;
      };
    };
  };

  home.stateVersion = "22.11";
  home.homeDirectory = "/home/ckenney";
}
