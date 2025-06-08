{ lib, self, ... }: {
  imports = [
    ../../profiles/nixos
    ../../roles/nixos

    self.outputs.modules
  ];

  x.home = {
    browser.zen.enable = true;
    editor.neovim = {
      enable = true;
      nightly = true;
    };
  };

  home.stateVersion = lib.mkForce "22.11";
  home.homeDirectory = "/home/ckenney";
}
