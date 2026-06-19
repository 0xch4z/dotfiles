_: {
  den.aspects.tools-secrets.homeManager =
    { pkgs, ... }:
    {
      programs.rbw = {
        enable = true;
        settings = {
          email = "charlesc.kenney@gmail.com";
          lock_timeout = 3600 * 10;
          pinentry = with pkgs; (if pkgs.stdenv.hostPlatform.isDarwin then pinentry_mac else pinentry-gnome3);
        };
      };

      home = {
        packages = with pkgs; [
          age
          pass
          sops
          (if pkgs.stdenv.hostPlatform.isDarwin then pinentry_mac else pinentry-gnome3)
        ];

      };
    };
}
