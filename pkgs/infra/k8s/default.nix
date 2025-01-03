{pkgs, ...}: {
  home.shellAliases = {
    k = "kubectl";
  };
  home.packages = with pkgs; [
    argocd
    clusterctl
    clusterctl
    helm-ls
    kdash
    kns-fork.kns
    kubecm
    kubectl
    kubectl-images
    kubectl-ktop
    #kubectl-node-shell
    kubectl-view-secret
    kubernetes-helm
    k9s
    minikube
    stern
  ];
}
