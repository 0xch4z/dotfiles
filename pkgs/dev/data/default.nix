{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      csvq
      delta
      diffutils
      jq
      jsonfmt
      yamlfmt
      yamllint
      yaml-language-server
      yq-go
    ];
  };
}
