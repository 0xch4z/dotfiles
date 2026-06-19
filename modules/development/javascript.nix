_: {
  den.aspects.javascript.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        #deno # bruh this takes so fucking long to build... leaving out for now
        eslint_d
        nodejs
        pnpm
        prettierd
        tailwindcss-language-server
        typescript-language-server
      ];
      home.sessionVariables = {
        NPM_CONFIG_PREFIX = "$HOME/.npm-global";
      };
      home.sessionPath = [ "$HOME/.npm-global/bin" ];
    };
}
