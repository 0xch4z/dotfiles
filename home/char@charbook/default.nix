{ den, ... }:
{
  den.aspects.charbook.char = {
    includes = [
      den.aspects.workstation
      den.aspects.mac-workstation
      den.aspects._1pass
      den.aspects.sketchybar
    ];

    homeManager = {
      x.home.editor.neovim.nightly = true;

      x.home.desktop.aerospace.workspaceMap = {
        "0" = [
          "Studio Display"
          "main"
        ];
        "1" = [
          "Studio Display"
          "main"
        ];
        "2" = [
          "Studio Display"
          "main"
        ];
        "3" = [
          "Studio Display"
          "main"
        ];
        "4" = [
          "Studio Display"
          "main"
        ];
        "5" = [
          "LU28R55"
          "main"
        ];
        "6" = [
          "DELL U2718Q"
          "main"
        ];
        "7" = [
          "DELL U2718Q"
          "main"
        ];
        "8" = [
          "DELL U2718Q"
          "main"
        ];
        "9" = [
          "DELL U2718Q"
          "main"
        ];
      };

      home.stateVersion = "22.11";
      home.homeDirectory = "/Users/char";
    };
  };
}
