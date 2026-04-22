{ pkgs, config, lib, ... }: {
  config = lib.mkIf config.x.home.tools.infrastructure.ansible.enable {
    home.packages = with pkgs; [ ansible ansible-lint ];
  };
}
