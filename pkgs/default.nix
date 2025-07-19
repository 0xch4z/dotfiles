{pkgs}: with pkgs; {
  caffeine-bin = callPackage ./darwin/utility/caffine.nix {};
  is-macbook-display-only = callPackage ./darwin/utility/is-macbook-display-only {};
  sbarlua = callPackage ./darwin/utility/sbarlua.nix {};
}
