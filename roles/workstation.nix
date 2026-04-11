{ lib, config, ... }: {
  config = lib.mkIf config.x.profile.workstation {
    home.sessionVariables = { AVANTE_DEFAULT_PROVIDER = "claude-code"; };

    programs.home-manager.enable = lib.mkDefault true;

    x.home = {
      development.ai.claude.enable = lib.mkDefault true;
      fonts.enable = lib.mkDefault true;

      applications = {
        browser = {
          chromium.enable = lib.mkDefault true;
          firefox.enable = lib.mkDefault true;
          zen.enable = lib.mkDefault true;
        };
        music = { spotify.enable = lib.mkDefault true; };
        passwords = { bitwarden.enable = lib.mkDefault true; };
        terminal.alacritty.enable = lib.mkDefault true;
        terminal.kitty.enable = lib.mkDefault true;
      };
      development.enable = lib.mkDefault true;
      editor = {
        neovim.enable = lib.mkDefault true;
        vscode.enable = lib.mkDefault true;
      };
      tools = {
        coreutils = "full";

        containers.enable = lib.mkDefault true;
        file.enable = lib.mkDefault true;
        infrastructure.enable = lib.mkDefault true;
        io.enable = lib.mkDefault true;
        networking.enable = lib.mkDefault true;
        productivity.enable = lib.mkDefault true;
        secrets.enable = lib.mkDefault true;
      };
    };
  };
}
