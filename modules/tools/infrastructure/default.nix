{ den, ... }:
{
  den.aspects.infrastructure.includes = [
    den.aspects.ansible
    den.aspects.aws
    den.aspects.cloudflare
    den.aspects.equinix
    den.aspects.hetzner
    den.aspects.k8s
    den.aspects.linode
    den.aspects.nats
    den.aspects.packer
    den.aspects.terraform
    den.aspects.vsphere
  ];
}
