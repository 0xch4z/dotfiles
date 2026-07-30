{ pkgs, ... }:
let
  shelp = pkgs.writeShellApplication {
    name = "shelp";
    text = builtins.readFile ./scripts/shelp.sh;
  };
in
{
  programs.zoxide = {
    enable = true;
  };

  home.packages = with pkgs; [
    bats
    bash-language-server
    shelp
  ];
}
