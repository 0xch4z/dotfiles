{pkgs, ...}: {
  home.shellAliases = {
    k = "kubectl";
  };
  home.packages = with pkgs; [
    argocd
    clusterctl
    helm-ls
    kdash
    kns
    #kubetrim
    kubecm
    kubecolor
    kubectl
    kubectl-images
    kubectl-ktop
    kubectl-neat
    kubectl-images
    kubectl-tree
    kubectl-view-secret
    kubernetes-helm
    k9s
    minikube
    stern
  ];
}
