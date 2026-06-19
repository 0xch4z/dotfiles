{ ... }:
{
  den.aspects.vscode.homeManager =
    {
      pkgs,
      ...
    }:
    {
      programs.vscode = {
        enable = false;
        package = pkgs.vscodium.fhs;

        profiles.default = {
          userSettings = {
            "vim.easymotion" = true;
            "vim.hlsearch" = true;
            "vim.leader" = "<space>";
            "vim.disableExtension" = false;
            "vim.useSystemClipboard" = true;
            "vim.statusBarColorControl" = true;
          };

          extensions = with pkgs.vscode-extensions; [
            golang.go
            ms-vscode.cmake-tools
            ms-vscode.cpptools
            ms-python.python
            vscodevim.vim
          ];
        };
      };
    };
}
