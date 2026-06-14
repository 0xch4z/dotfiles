{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.x.home.development.enable {
    home.packages =
      with pkgs;
      [
        bashInteractive
        devenv
        direnv
        shellcheck
        shfmt
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        bubblewrap
      ];
  };
}
