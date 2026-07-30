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
      extraSubstituters = [ "https://cache.numtide.com" ];
      extraTrustedPublicKeys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
    };
  };
}
