{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (self.lib) mkEnableOption mkIf;

  cfg = config.x.home.applications.terminal.kitty;
  kittyPackage =
    let
      package = config.x.home.graphics.wrapPackage pkgs.kitty;
    in
    if pkgs.stdenv.hostPlatform.isDarwin then
      package.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          app="$out/Applications/kitty.app"
          /usr/bin/codesign \
            --force \
            --deep \
            --sign - \
            --identifier net.kovidgoyal.kitty \
            --requirements '=designated => identifier "net.kovidgoyal.kitty"' \
            "$app"
          /usr/bin/codesign --verify --deep --strict --verbose=2 "$app"
        '';
      })
    else
      package;
  keshPath = lib.makeBinPath [
    kittyPackage
    pkgs.x.kesh
    pkgs.zoxide
    pkgs.git
    pkgs.openssh
    pkgs.gh
  ];
  keshAction = "launch --type=overlay --env=PATH=${keshPath} ${lib.getExe pkgs.x.kesh}";
  tuiosPath = lib.makeBinPath [
    pkgs.x.tuios
    pkgs.fish
    pkgs.coreutils
    pkgs.git
    pkgs.openssh
  ];
  tuiosAction = "launch --type=tab --cwd=current --spacing=padding=0 --env=PATH=${tuiosPath}:${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin --env=SHELL=${lib.getExe pkgs.fish} ${lib.getExe pkgs.x.tuios} attach kitty -c";

  scrollbackPager = pkgs.writeShellScript "kitty-scrollback-pager" ''
    line="$1"
    ${pkgs.perl}/bin/perl -0pe 's{\e\]66;[^;]*;([^\x07\x1b]*)(?:\x07|\x1b\x5c)}{$1}g' |
      KITTY_SCROLLBACK_LINE="$line" exec ${config.programs.neovim.package}/bin/nvim -u NONE -n \
        +'luafile ${./kitty-scrollback.lua}' -
  '';
in
{
  options.x.home.applications.terminal.kitty = {
    enable = mkEnableOption "Enable kitty module.";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.x.kesh
    ];

    home.file.".local/share/kitty/sessions/kitty.kitty-session".text = ''
      launch
    '';

    programs.kitty = {
      enable = true;
      package = kittyPackage;

      settings = {
        active_tab_background = "#000000";
        active_tab_font_style = "bold";
        active_tab_foreground = "#dddddd";
        allow_remote_control = "socket-only";
        background_opacity = "0.9";
        dynamic_background_opacity = "yes";
        enabled_layouts = "splits,stack";
        font_family = config.x.home.theme.font.mono;
        disable_ligatures = "never";
        hide_window_decorations = "titlebar-only";
        inactive_tab_background = "#000000";
        inactive_tab_foreground = "#666666";
        listen_on = "unix:/tmp/kitty-{kitty_pid}";
        window_margin_width = 6;
        window_padding_width = 4;
        placement_strategy = "center";
        macos_option_as_alt = "left";
        scrollback_pager = "${scrollbackPager} INPUT_LINE_NUMBER";
        shell = "${pkgs.fish}/bin/fish --login --interactive";
        startup_session = "~/.local/share/kitty/sessions/kitty.kitty-session";
        tab_bar_align = "center";
        tab_bar_background = "#000000";
        tab_bar_edge = "top";
        tab_bar_filter = "session:~ or session:^$";
        tab_bar_margin_height = "0 1";
        tab_bar_min_tabs = 2;
        tab_bar_style = "separator";
        tab_separator = " | ";
        tab_title_max_length = 24;
        tab_title_template = " {title} ";
      };

      keybindings."ctrl+q>-" = "combine : goto_layout splits : launch --location=hsplit --cwd=current";
      keybindings."ctrl+q>|" = "combine : goto_layout splits : launch --location=vsplit --cwd=current";
      keybindings."ctrl+q>a" = "combine : scroll_to_prompt -1 : show_scrollback";
      keybindings."ctrl+q>c" = "new_tab_with_cwd";
      keybindings."ctrl+q>ctrl+q" = "combine : scroll_to_prompt -1 : show_scrollback";
      keybindings."ctrl+q>ctrl+s" = keshAction;
      keybindings."ctrl+q>h" = "neighboring_window left";
      keybindings."ctrl+q>j" = "neighboring_window down";
      keybindings."ctrl+q>k" = "neighboring_window up";
      keybindings."ctrl+q>l" = "neighboring_window right";
      keybindings."ctrl+q>n" = "next_tab";
      keybindings."ctrl+q>p" = "launch --type=background kitten quick-access-terminal --detach";
      keybindings."ctrl+q>s" = keshAction;
      keybindings."ctrl+q>t" = tuiosAction;
      keybindings."ctrl+q>/" =
        "launch --allow-remote-control kitty +kitten ${pkgs.x.kitty-search}/share/kitty/kitty-search/search.py";
      keybindings."ctrl+q>x" = "close_window";
      keybindings."ctrl+shift+h" = "combine : scroll_to_prompt -1 : show_scrollback";

      mouseBindings."right press" =
        "ungrabbed kitten ${pkgs.x.kitty-action-menu}/share/kitty/kitty-action-menu/action_menu.py";

      extraConfig = ''
        map ctrl+h neighboring_window left
        map ctrl+j neighboring_window down
        map ctrl+k neighboring_window up
        map ctrl+l neighboring_window right
        map --when-focus-on var:IS_VIM=true ctrl+h
        map --when-focus-on var:IS_VIM=true ctrl+j
        map --when-focus-on var:IS_VIM=true ctrl+k
        map --when-focus-on var:IS_VIM=true ctrl+l
      '';
    };
  };
}
