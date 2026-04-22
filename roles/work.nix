{ lib, config, ... }: {
  config = lib.mkIf config.x.profile.work {
  };
}
