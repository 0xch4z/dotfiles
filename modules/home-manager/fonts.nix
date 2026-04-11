{ self, config, pkgs, lib, ... }:
let
  inherit (self.lib) mkEnableOption mkIf;

  cfg = config.x.home.fonts;
in {
  options.x.home.fonts = {
    enable = mkEnableOption "enable fonts";
    apple-nerdfont.enable = mkEnableOption "enable apple-nerdfont";
  };

  config = mkIf cfg.enable {
    fonts.fontconfig = {
      enable = lib.mkDefault true;

      defaultFonts = {
        monospace = [ "Source Code Pro" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
    };

    home.packages = with pkgs; [
      inter
      noto-fonts
      noto-fonts-color-emoji
      font-awesome
      fira-mono
      nerd-fonts.fira-code
      lato
      fontconfig
      (mkIf cfg.apple-nerdfont.enable x.apple-nerdfont)
    ];
  };
}
