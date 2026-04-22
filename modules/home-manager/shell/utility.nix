{ pkgs, ... }:
{
  programs.zoxide = {
    enable = true;
  };
  programs.bash = {
    enable = true;
  };

  home.packages = with pkgs; [
    bash-language-server
  ];
}
