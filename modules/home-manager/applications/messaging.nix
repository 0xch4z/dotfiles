args@{
  config,
  self,
  pkgs,
  lib,
  ...
}:
let
  inherit (self.lib) mkIf mkDesktopEnabledOption;

  cfg = config.x.home.applications.messaging;

  slack-wayland = pkgs.unstable.slack.overrideAttrs (prev: {
    installPhase =
      (prev.installPhase or "")
      + ''
        wrapProgram $out/bin/slack \
          --add-flags "--enable-features=UseOzonePlatform,WaylandWindowDecorations" \
          --add-flags "--ozone-platform=wayland"
      '';
  });
in
{
  options.x.home.applications.messaging = {
    slack.enable = mkDesktopEnabledOption config "Enable Slack home-manager module.";
  };

  config = mkIf (cfg.slack.enable && pkgs.stdenv.hostPlatform.isLinux) {
    home.packages = [ slack-wayland ];

    # Local Slack settings: hide menu bar, dark theme
    xdg.configFile."Slack/local-settings.json".text = builtins.toJSON {
      useHwAcceleration = true;
      autoHideMenuBar = true;
    };
  };
}
