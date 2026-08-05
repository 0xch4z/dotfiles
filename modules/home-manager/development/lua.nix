{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.x.home.development.enable {
    home.packages = with pkgs; [
      luajit
      luajitPackages.lua-lsp
      luajitPackages.luacheck
      luajitPackages.luarocks
      selene
      stylua
      lua-language-server
    ];
    home.sessionPath = [ "$HOME/.luarocks/bin" ];

    x.home.development.lsp.servers.lua = {
      package = pkgs.lua-language-server;
      opencode = "lua-ls";
      extensionToLanguage = {
        ".lua" = "lua";
      };
    };
  };
}
