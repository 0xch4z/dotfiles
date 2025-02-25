{ pkgs, lib, ... }:
let
  treesitterWithGrammars = (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
  ]));
in
{
  home.packages = with pkgs; [
    #elixir-ls
    #gopls
    #lua-language-server
    nil
    # nodePackages_latest.pyright
    pyright
    #rubyPackages_3_4.solargraph
    ripgrep
    #rust-analyzer-unwrapped
    #terraform-ls
  ];

  home.sessionVariables = {
    NVIM_TREESITTER_SKIP_PARSER_INSTALL = "1";
  };

  xdg.configFile."nvim/parser".source = "${pkgs.symlinkJoin {
      name = "treesitter-parsers";
      paths = (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: with plugins; [
        bash
        comment
        css
        dockerfile
        elixir
        fish
        gitattributes
        gitignore
        go
        gomod
        gowork
        hcl
        javascript
        jq
        json5
        json
        lua
        make
        markdown
        nix
        python
        ruby
        rust
        toml
        typescript
        vue
        yaml
      ])).dependencies;
    }}/parser";

  programs.neovim = {
    enable = true;
    # package = pkgs.neovim-nightly;
    vimAlias = true;
    coc.enable = false;
    withNodeJs = true;
    defaultEditor = true;

    plugins = [
      treesitterWithGrammars
    ];
  };

  # Adapted from: https://github.com/Kidsan/nixos-config/blob/466dae0d720b229f97e9ece369e661db106f41c0/home/programs/neovim/default.nix#L71
  #
  # Treesitter is configured as a locally developed module in lazy.nvim
  # we hardcode a symlink here so that we can refer to it in our lazy config
  home.file."./.local/share/nvim/nix/nvim-treesitter/" = {
    recursive = true;
    source = treesitterWithGrammars;
  };
}
