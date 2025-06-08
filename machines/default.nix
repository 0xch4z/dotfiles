self @ { lib, constants, ... }:
let
  inherit (builtins) elemAt;
  inherit (constants) defaultArch;
  inherit (lib) lists homeConfigurationFactory machineConfigurationFactory;
  inherit (lists) foldl';

  buildMachine = hostname:
    {
      arch ? defaultArch,
      #defaultUser,
      os,
      variant ? os,
      wsl ? false,
    }:
    let
      # validate wsl
      _ = if wsl && os != "linux"
        then throw "WSL can only be enabled for linux"
        else null;

      platform = "${arch}-${os}";
      system = platform;

      users = self.users.${hostname};

      # set to defaultUser or users[0]
      actualDefaultUser = elemAt users 0;

      # key: user
      homes = foldl'
        (acc: user:
          let
            userhost = "${user}@${hostname}";
            userConfig = rec {
              inherit arch homes hostname os platform system user userhost variant;

              module = ../home/${userhost};
              configuration = homeConfigurationFactory userConfig;
            };
          in acc // {
            ${userhost} = userConfig;
          }) {} users;

      machine = {
        inherit arch homes hostname os platform system users variant wsl;

        user = actualDefaultUser;
        configuration = machineConfigurationFactory machine;
      };
    in
      machine;
in
  lib.mapAttrs buildMachine {
    Charlies-MacBook-Pro = { os = "darwin"; };
    USMK9RK6N3FN2 = { os = "darwin"; };
    CHAKENNE-M-2JJJ = { os = "darwin"; };
    charbox2wsl = { os = "linux"; arch = "x86_64"; variant = "nixos"; wsl = true; };
    charbox = { os = "linux"; arch = "x86_64"; variant = "nixos"; };
    charbit = { os = "linux"; arch = "x86_64"; variant = "nixos"; };
  }
