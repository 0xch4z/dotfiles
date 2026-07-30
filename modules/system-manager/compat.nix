{ lib, ... }:
{
  options.security.dhparams = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    internal = true;
    description = "Compatibility stub for imported NixOS nginx modules.";
  };
}
