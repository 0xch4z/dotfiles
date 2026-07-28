{
  config,
  self,
  pkgs,
  lib,
  ...
}:
let
  inherit (self.lib) mkIf mkEnableOption;

  shared = import ./shared.nix { inherit lib; };
  cfg = config.x.home.applications.browser.chromium;

  policies = {
    ExtensionInstallSources = [
      "https://clients2.google.com/service/update2/crx"
      "https://chrome.google.com/webstore/*"
    ];
    BookmarkBarEnabled = false;
    TabGroupsEnabled = false;
    BrowserSigninEnabled = 0;
    SyncDisabled = true;
    PasswordManagerEnabled = false;
    SpellcheckEnabled = true;
    DefaultSearchProviderEnabled = true;
    DefaultSearchProviderName = "Brave";
    DefaultSearchProviderSearchURL = "https://search.brave.com/search?q={searchTerms}";
    DefaultSearchProviderKeyword = "b";
    ManagedBookmarks = shared.toChromiumBookmarks;
    ManagedSearchEngines = [
      {
        name = "Brave";
        keyword = "b";
        search_url = "https://search.brave.com/search?q={searchTerms}";
        is_default = true;
      }
    ]
    ++ shared.toChromiumSearchEngines;
  };
in
{
  options.x.home.applications.browser.chromium = {
    enable = mkEnableOption "Enable Ungoogled Chromium home-manager module.";

    ozonePlatform = lib.mkOption {
      type = lib.types.enum [
        "wayland"
        "x11"
      ];
      default = "wayland";
      description = "Chromium Ozone platform.";
    };

    nvidiaWorkarounds.enable = mkEnableOption "NVIDIA-specific Chromium GPU workarounds";
  };

  config = mkIf (cfg.enable && !pkgs.stdenv.hostPlatform.isDarwin) {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "chromium-browser.desktop";
        "x-scheme-handler/http" = "chromium-browser.desktop";
        "x-scheme-handler/https" = "chromium-browser.desktop";
        "x-scheme-handler/about" = "chromium-browser.desktop";
        "x-scheme-handler/unknown" = "chromium-browser.desktop";
      };
    };

    xdg.configFile."mimeapps.list".force = true;

    xdg.configFile."chromium/policies/managed/policies.json".text = builtins.toJSON policies;

    programs.chromium = {
      enable = true;
      package = config.x.home.graphics.wrapPackage pkgs.ungoogled-chromium;

      commandLineArgs = [
        "--ozone-platform=${cfg.ozonePlatform}"
        "--enable-features=${
          lib.concatStringsSep "," (
            [
              "VaapiVideoDecoder"
              "VaapiVideoEncoder"
              "WebRTCPipeWireCapturer"
              "WebUIDarkMode"
              "SidePanelPinning"
            ]
            ++ lib.optionals cfg.nvidiaWorkarounds.enable [
              "VaapiOnNvidiaGPUs"
              "VaapiIgnoreDriverChecks"
              "Vulkan"
              "DefaultANGLEVulkan"
              "VulkanFromANGLE"
            ]
          )
        }"

        "--enable-gpu-rasterization"
        "--ignore-gpu-blocklist"

        # minimal UI
        "--force-dark-mode"
        "--gtk-version=4"
        "--hide-sidepanel-button"
        "--remove-tabsearch-button"
      ];

      dictionaries = [
        pkgs.hunspellDictsChromium.en_US
      ];

      extensions = shared.toChromiumExtensions;
    };
  };
}
