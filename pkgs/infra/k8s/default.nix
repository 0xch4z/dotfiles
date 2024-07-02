{pkgs, ...}: {
  home.packages = with pkgs; [
    clusterctl
    kdash
    kns-fork.kns
    kubectl
    k9s
  ];
}
