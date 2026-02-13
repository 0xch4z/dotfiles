{ pkgs, config, lib, ... }: {
  config = lib.mkIf config.x.home.development.enable {
    home.packages = with pkgs; [
      #deno # bruh this takes so fucking long to build... leaving out for now
      nodePackages."@tailwindcss/language-server"
      nodePackages.eslint_d
      nodePackages.pnpm
      nodePackages.typescript-language-server
      nodejs
      prettierd
    ];
    home.sessionVariables = { NPM_CONFIG_PREFIX = "$HOME/.npm-global"; };
    home.sessionPath = [ "$HOME/.npm-global/bin" ];
  };
}
