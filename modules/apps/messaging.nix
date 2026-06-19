_: {
  den.aspects.messaging.homeManager =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib) mkIf;

      slack-wayland = pkgs.unstable.slack.overrideAttrs (prev: {
        installPhase = (prev.installPhase or "") + ''
          wrapProgram $out/bin/slack \
            --add-flags "--enable-features=UseOzonePlatform,WaylandWindowDecorations" \
            --add-flags "--ozone-platform=wayland"
        '';
      });
    in
    {
      config = mkIf pkgs.stdenv.hostPlatform.isLinux {
        home.packages = [ slack-wayland ];

        # Local Slack settings: hide menu bar, dark theme
        xdg.configFile."Slack/local-settings.json".text = builtins.toJSON {
          useHwAcceleration = true;
          autoHideMenuBar = true;
        };
      };
    };
}
