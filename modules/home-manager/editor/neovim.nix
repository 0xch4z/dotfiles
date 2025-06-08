{ self, homeDir, pkgs, config, lib, ... }:
let
  inherit (lib) mkEnableOption;
  cfg = config.x.home.editor.neovim;

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
  options.x.home.editor.neovim = {
    enable = mkEnableOption "Enable neovim module.";
    nightly = mkEnableOption "Install nightly build of neovim";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nil     # nil language server
      fzf     # several plugins depend on native fzf install
      ripgrep # ^ same with ripgrep
    ];

    programs.neovim = {
      enable = true;

      package = if cfg.nightly then (
          self.inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
        ) else pkgs.neovim;

      viAlias = true;
      vimAlias = true;

      coc.enable = false;
      withNodeJs = true;
      defaultEditor = true;
    };

    # Symlink actual neovim lua config source.
    # git clone https://github.com/0xch4z/neovim.git
    xdg.configFile.neovim = {
      enable = true;
      recursive = true;
      # NB: this line makes an assumption that this repo exists at `$HOME/.dotfiles`.
      # Setting an absolute path to the symlink source is the only way to avoid
      # write protection.
      source = config.lib.file.mkOutOfStoreSymlink "${homeDir}/.dotfiles/nvim/.config/nvim";
      target = "nvim";
    };

    home.sessionVariables = {
      # The below environment variables tell neovim not to install grammars via
      # the nvim-treesitter plugin.
      NVIM_TREESITTER_SKIP_PARSER_INSTALL = "1";
      # Grammars will be installed to the following path, which is made
      # available to neovim with the below environment variable.
      LOCAL_NVIM_TREESITTER_PATH = "${homeDir}/${localTreesitterPath}";
    };

    # Adapted from: https://github.com/Kidsan/nixos-config/blob/466dae0d720b229f97e9ece369e661db106f41c0/home/programs/neovim/default.nix#L71
    #
    # Treesitter is configured as a locally developed module in lazy.nvim
    # we hardcode a symlink here so that we can refer to it in our lazy config
    home.file."./${localTreesitterPath}" = {
      recursive = true;
      source = treesitterWithGrammars;
    };
  };
}
