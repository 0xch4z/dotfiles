{ config, lib, ... }:
let
  user = config.home.username;
in {
  config = {
    home.sessionPath = lib.mkAfter [
      "/etc/profiles/per-user/${user}/bin"
    ];
  };
}
