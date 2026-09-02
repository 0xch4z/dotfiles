{
  config,
  pkgs,
  self,
  ...
}:
let
  inherit (self.lib) mkEnableOption mkIf;

  cfg = config.x.home.applications.terminal.kitty;
in
{
  options.x.home.applications.terminal.kitty = {
    enable = mkEnableOption "Enable kitty module.";
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      package = config.x.home.graphics.wrapPackage pkgs.kitty;

      settings = {
        background_opacity = "0.9";
        dynamic_background_opacity = "yes";
        font_family = config.x.home.theme.font.mono;
        disable_ligatures = "never";
        hide_window_decorations = "titlebar-only";
        window_margin_width = 6;
        window_padding_width = 4;
        placement_strategy = "center";
        macos_option_as_alt = "left";
        shell = "${pkgs.fish}/bin/fish --login --interactive";
      };
    };
  };
}
