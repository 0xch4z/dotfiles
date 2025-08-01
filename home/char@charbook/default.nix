{ lib, user, pkgs, ... }: {
  x.role = "mac-workstation";

  x.home.applications.passwords._1pass.enable = true;
  x.home.editor.neovim.nightly = true;
  x.home.taskbar.sketchybar.enable = true;

  x.home.desktop.aerospace.workspaceMap = {
    "0" = ["Studio Display" "main"];
    "1" = ["Studio Display" "main"];
    "2" = ["Studio Display" "main"];
    "3" = ["Studio Display" "main"];
    "4" = ["Studio Display" "main"];
    "5" = ["LU28R55" "main"];
    "6" = ["DELL U2718Q" "main"];
    "7" = ["DELL U2718Q" "main"];
    "8" = ["DELL U2718Q" "main"];
    "9" = ["DELL U2718Q" "main"];
  };

  home.packages = with pkgs; [
    x.apple-nerdfont
  ];

  home.stateVersion = lib.mkForce "22.11";
  home.homeDirectory = "/Users/${user}";
}
