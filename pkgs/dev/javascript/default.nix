{
  config,
  pkgs,
  ...
}: {
  home = {
    packages = with pkgs; [
      nodePackages."@tailwindcss/language-server"
      nodePackages.eslint_d
      nodePackages.pnpm
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodejs
      prettierd
    ];
    sessionPath = [
      "${config.xdg.configHome}/npm/npm-packages/bin"
    ];
  };
}
