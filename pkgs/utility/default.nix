{pkgs, ...}: {
  imports = [
    ./nix
    ./zoxide
  ];

  home.packages = with pkgs; [
    fzf
  ];
}
