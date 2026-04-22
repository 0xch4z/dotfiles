{ self, config, lib, ... }:
let
  cfg = config.x.home.tools.infrastructure;
in {
  options.x.home.tools.infrastructure = {
    enable = self.lib.mkEnableOption "enable infrastructure tools";

    ansible.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "enable Ansible tools";
    };
    aws.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "enable AWS tools";
    };
    cloudflare.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "enable Cloudflare tools";
    };
    equinix.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "enable Equinix tools";
    };
    hetzner.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "enable Hetzner tools";
    };
    k8s.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "enable Kubernetes tools";
    };
    linode.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "enable Linode tools";
    };
    nats.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "enable NATS tools";
    };
    packer.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "enable Packer";
    };
    terraform.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "enable Terraform tools";
    };
    vsphere.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "enable vSphere tools";
    };
  };

  imports = [
    ./ansible.nix
    ./aws.nix
    ./cloudflare.nix
    ./equinix.nix
    ./hetzner.nix
    ./k8s.nix
    ./linode.nix
    ./nats.nix
    ./packer.nix
    ./terraform.nix
    ./vsphere.nix
  ];
}
