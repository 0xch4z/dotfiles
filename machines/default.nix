self @ { lib, constants, ... }:
let
  inherit (builtins) elemAt trace toJSON;
  inherit (constants) defaultArch;
  inherit (lib) lists homeConfigurationFactory machineConfigurationFactory;
  inherit (lists) foldl';

  buildMachine = hostname:
    {
      arch ? defaultArch,
      #defaultUser,
      os,
    }:
    let
      platform = "${arch}-${os}";
      users = self.users.${hostname};
      system = platform;

      # set to defaultUser or users[0]
      actualDefaultUser = elemAt users 0;

      # key: user
      homes = foldl'
        (acc: user:
          let
            userhost = "${user}@${hostname}";
            userConfig = rec {
              inherit arch homes hostname os platform system user userhost;

              module = ../home/${userhost};
              configuration = homeConfigurationFactory userConfig;
            };
          in acc // {
            ${userhost} = userConfig;
          }) {} users;

      machine = rec {
        inherit arch homes hostname os platform system users;

        user = actualDefaultUser;
        configuration = machineConfigurationFactory machine;
      };
    in
      machine;
in
  lib.mapAttrs buildMachine {
    Charlies-MacBook-Pro = { os = "darwin"; };
    USMK9RK6N3FN2 = { os = "darwin"; };
    #charbox2wsl = { os = "nixos"; };
  }
