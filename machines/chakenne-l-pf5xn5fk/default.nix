{ user, ... }:
{
  x.system = {
    apparmor.bubblewrap.enable = true;

    docker = {
      enable = true;
      users = [ user ];
    };

    nix = {
      enable = true;
      trustedUsers = [ user ];
    };
  };
}
