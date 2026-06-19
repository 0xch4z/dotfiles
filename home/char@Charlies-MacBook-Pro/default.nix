{ den, ... }:
{
  den.aspects.Charlies-MacBook-Pro.char = {
    includes = [
      den.aspects.workstation
      den.aspects.mac-workstation
    ];

    homeManager = {
      home.stateVersion = "22.11";
      home.homeDirectory = "/Users/char";
    };
  };
}
