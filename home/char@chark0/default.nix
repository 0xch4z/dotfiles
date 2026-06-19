{ den, ... }:
{
  den.aspects.chark0.char = {
    includes = [
      den.aspects.workstation
      (den.batteries.user-shell "fish")
      den.batteries.primary-user
    ];

    homeManager = {
      home.stateVersion = "24.11";
      home.homeDirectory = "/home/char";
    };
  };
}
