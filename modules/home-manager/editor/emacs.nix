{
  config,
  homeDir,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.x.home.editor.emacs;
in
{
  options.x.home.editor.emacs.enable = lib.mkEnableOption "Emacs home-manager module";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      emacs-lsp-booster
      fd
      imagemagick
    ];
    home.shellAliases.e = "emacs -nw";

    programs.emacs = {
      enable = true;
      package = pkgs.unstable.emacs31-nox;
    };

    xdg.configFile.emacs = {
      source = config.lib.file.mkOutOfStoreSymlink "${homeDir}/.dotfiles/emacs/.config/emacs";
      target = "emacs";
    };
  };
}
