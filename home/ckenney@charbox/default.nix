{ lib, self, pkgs, ... }: {
  imports = [
    ../../profiles/nixos

    self.outputs.modules
  ];

  x.role = "nix-workstation";

  x.home.editor.neovim.nightly = true;

  home.stateVersion = lib.mkForce "22.11";
  home.homeDirectory = "/home/ckenney";
}
