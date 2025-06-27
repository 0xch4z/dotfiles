{pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.development.enable {
    # TODO: re-enable when devenv patch is fixed
    # programs.direnv = {
    #   enable = true;
    #   nix-direnv.enable = true;
    # };

    home.packages = with pkgs; [
      nixd
      #devcontainer # maybe I'll never have to use this again
      #devpod       # ^
      #devenv       # broken right now, and not needed; /nix/store/3bal0hf39zp5p75xz45gihanq9493cvb-ghsa-g948-229j-48j3-2.24.patch (hunk 2)
    ];
  };
}
