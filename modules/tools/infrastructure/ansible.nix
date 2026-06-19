_: {
  den.aspects.ansible.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ansible
        ansible-lint
      ];
    };
}
