{ homeDir, config, pkgs, lib, user, ... }: {
  x.role = "mac-workstation";
  x.home.applications.passwords._1pass.enable = true;
  x.home.editor.neovim.nightly = true;
  x.home.secrets.enable = true;
  x.home.taskbar.sketchybar.enable = true;

  home.stateVersion = lib.mkForce "22.11";
  home.homeDirectory = "/Users/${user}";

  home.packages = with pkgs; [
    gh
  ];


### SKETCHYBAR

  # entrypoint for config
### AEROSPACE

  services.jankyborders = {
    enable = true;
    settings = {
      hidpi = "on";
      active_color = "0xff69b4ff";
      inactive_color = "0x00ffffff";
    };
  };

}
