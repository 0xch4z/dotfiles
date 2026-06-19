{ den, ... }:
{
  den.aspects.games = {
    includes = [
      den.aspects.rs
    ];

    homeManager = {
      programs.mangohud = {
        enable = true;
        settings = {
          fps = true;
          frame_timing = true;

          gpu_stats = true;
          gpu_temp = true;
          gpu_core_clock = true;
          gpu_power = true;

          cpu_stats = true;
          cpu_temp = true;
          cpu_mhz = true;

          ram = true;
          vram = true;

          position = "top-left";
          font_size = 20;
          background_alpha = "0.4";
          toggle_hud = "Shift_R+F12";
        };
      };
    };
  };
}
