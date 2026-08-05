{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.x.home.development.enable {
    home.packages = with pkgs; [
      #deno # bruh this takes so fucking long to build... leaving out for now
      eslint_d
      nodejs
      pnpm
      prettierd
      tailwindcss-language-server
      typescript-language-server
    ];
    x.home.development.lsp.servers = {
      typescript = {
        package = pkgs.typescript-language-server;
        args = [ "--stdio" ];
        opencode = "typescript";
        extensionToLanguage = {
          ".ts" = "typescript";
          ".mts" = "typescript";
          ".cts" = "typescript";
          ".tsx" = "typescriptreact";
          ".js" = "javascript";
          ".mjs" = "javascript";
          ".cjs" = "javascript";
          ".jsx" = "javascriptreact";
        };
      };

      tailwindcss = {
        package = pkgs.tailwindcss-language-server;
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".css" = "css";
        };
      };
    };

    home.sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };
    home.sessionPath = [ "$HOME/.npm-global/bin" ];
  };
}
