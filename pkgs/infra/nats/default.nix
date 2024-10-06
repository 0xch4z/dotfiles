{pkgs, ...}: {
  home.packages = with pkgs; [
    natscli
    nats-top
    nsc
  ];
}
