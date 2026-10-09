{ pkgs }: with pkgs;
{
  apple-nerdfont = callPackage ./fonts/apple-nerdfont.nix { };
  caffeine-bin = callPackage ./darwin/utility/caffine.nix { };
  actions-languageserver = callPackage ./development/actions-languageserver.nix { };
  is-macbook-display-only = callPackage ./darwin/utility/is-macbook-display-only { };
  hypr-persist = callPackage ./utility/hypr-persist.nix { };
  kesh = callPackage ./terminal/kitty/kesh.nix { };
  kitty-action-menu = callPackage ./terminal/kitty/kitty-action-menu.nix { };
  kitty-search = callPackage ./terminal/kitty/kitty-search.nix { };
  lspmux = callPackage ./development/lspmux.nix { };
  sbarlua = callPackage ./darwin/utility/sbarlua.nix { };
  tmux-picker = callPackage ./terminal/tmux/tmux-picker.nix { };
  tuios = callPackage ./terminal/tuios.nix { };
}
