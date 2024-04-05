{ pkgs, lib, ... }:
let

  treesitterWithGrammars = (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
    p.bash
    p.comment
    p.css
    p.dockerfile
    p.elixir
    p.fish
    p.gitattributes
    p.gitignore
    p.go
    p.gomod
    p.gowork
    p.hcl
    p.javascript
    p.jq
    p.json5
    p.json
    p.lua
    p.make
    p.markdown
    p.nix
    p.python
    p.ruby
    p.rust
    p.toml
    p.typescript
    p.vue
    p.yaml
  ]));
in
{
  home.packages = with pkgs; [
    elixir-ls
    gopls
    lua-language-server
    nil
    nodePackages_latest.pyright
    rubyPackages_3_3.solargraph
    rust-analyzer-unwrapped
    terraform-ls
  ];

  home.sessionVariables = {
    NVIM_TREESITTER_SKIP_PARSER_INSTALL = "1";
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
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
