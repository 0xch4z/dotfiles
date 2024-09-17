{...}: {
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "0.9";
      dynamic_background_opacity = "yes";
      # macos_traditional_fullscreen yes
      font_family = "Hack";
      disable_ligatures = "never";
      macos_hide_titlebar = "yes";
      hide_window_decorations = "titlebar-only";
    };
  };

  home.sessionVariables = {
    SHELL = "fish";
  };
}
