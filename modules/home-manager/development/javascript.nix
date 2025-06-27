{pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.development.enable {
    home.packages = with pkgs; [
      #deno # bruh this takes so fucking long to build... leaving out for now
      nodePackages."@tailwindcss/language-server"
      nodePackages.eslint_d
      nodePackages.pnpm
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodejs
      prettierd
    ];
    home.sessionPath = [
      "${config.xdg.configHome}/npm/npm-packages/bin"
    ];
  };
}
