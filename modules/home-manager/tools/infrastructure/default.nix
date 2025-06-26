{ self, ... }: {
  options.x.home.tools.infrastructure = {
    enable = self.lib.mkEnableOption "enable infrastructure tools";
  };

  imports = [
    ./ansible.nix
    ./aws.nix
    ./equinix.nix
    ./hetzner.nix
    ./k8s.nix
    ./linode.nix
    ./nats.nix
    ./packer.nix
    ./terraform.nix
  ];
}
