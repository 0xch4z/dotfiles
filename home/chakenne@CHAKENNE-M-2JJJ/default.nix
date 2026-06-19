{ den, ... }:
{
  den.aspects."CHAKENNE-M-2JJJ".chakenne = {
    includes = [
      den.aspects.workstation
      den.aspects.work
      den.aspects.mac-workstation
      den.aspects._1pass
      den.aspects.sketchybar
      den.aspects.home-secrets
    ];

    homeManager = {
      x.home.editor.neovim.nightly = true;

      home.stateVersion = "22.11";
      home.homeDirectory = "/Users/chakenne";
    };
  };
}
