{ homeDir, pkgs, ... }:
let
    # lazy config in neovim will use this path
    localTreesitterPath = ".local/share/nvim/nix/nvim-treesitter";

    # install treesitter with the following grammars
    treesitterWithGrammars = (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: with plugins; [
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

    ]));
in
{
  home.packages = with pkgs; [
    nil
    pyright
    ripgrep
  ];

  home.sessionVariables = {
    NVIM_TREESITTER_SKIP_PARSER_INSTALL = "1";
    LOCAL_NVIM_TREESITTER_PATH = "${homeDir}/${localTreesitterPath}";
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    coc.enable = false;
    withNodeJs = true;
    defaultEditor = true;
  };

  # Adapted from: https://github.com/Kidsan/nixos-config/blob/466dae0d720b229f97e9ece369e661db106f41c0/home/programs/neovim/default.nix#L71
  #
  # Treesitter is configured as a locally developed module in lazy.nvim
  # we hardcode a symlink here so that we can refer to it in our lazy config
  home.file."./${localTreesitterPath}" = {
    recursive = true;
    source = treesitterWithGrammars;
  };
}
