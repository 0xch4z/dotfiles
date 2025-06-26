{pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.tools.infrastructure.enable {
    home.packages = with pkgs; [
      awscli2
      awsume
      awsls
      eksctl
      s5cmd
    ];
  };
}
