{ den, ... }:
{
  den.aspects."USMK9RK6N3FN2".ckenney = {
    includes = [
      den.aspects.workstation
      den.aspects.work
      den.aspects.mac-workstation
    ];

    homeManager = {
      home.stateVersion = "22.11";
      home.homeDirectory = "/Users/ckenney";
    };
  };
}
