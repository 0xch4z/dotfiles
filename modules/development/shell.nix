_: {
  den.aspects.dev-shell.homeManager =
    {
      pkgs,
      lib,
      ...
    }:
    {
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
