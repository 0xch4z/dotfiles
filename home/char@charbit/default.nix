{ den, ... }:
{
  den.aspects.charbit.char = {
    includes = [
      den.aspects.workstation
      den.aspects.nix-workstation
      (den.batteries.user-shell "fish")
    ];

    homeManager = {
      home.stateVersion = "22.11";
      home.homeDirectory = "/home/char";
    };
  };
}
