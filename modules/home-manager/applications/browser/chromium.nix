{ config, self, pkgs, lib, ... }:
let
  inherit (self.lib) mkIf mkEnableOption;

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
    ManagedSearchEngines = [
      {
        name = "Brave";
        keyword = "b";
        search_url = "https://search.brave.com/search?q={searchTerms}";
        is_default = true;
      }
      {
        name = "Google";
        keyword = "g";
        search_url = "https://google.com/search?q={searchTerms}";
      }
      {
        name = "Github Code Search";
        keyword = "gh";
        search_url = "https://github.com/search?type=code&q={searchTerms}";
      }
      {
        name = "Nix Packages";
        keyword = "nix";
        search_url = "https://search.nixos.org/packages?query={searchTerms}";
      }
    ];
  };
in {
  options.x.home.applications.browser.chromium = {
    enable = mkEnableOption "Enable Ungoogled Chromium home-manager module.";
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

    xdg.configFile."chromium/policies/managed/policies.json".text =
      builtins.toJSON policies;

    programs.chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;

      commandLineArgs = [
        "--ozone-platform=wayland"
        "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,WebRTCPipeWireCapturer"
        "--enable-gpu-rasterization"
        # "--enable-zero-copy" # known issue with NVIDIA
        "--ignore-gpu-blocklist"

        # minimal UI
        "--force-dark-mode"
        "--enable-features=WebUIDarkMode,SidePanelPinning"
        "--gtk-version=4"
        "--hide-sidepanel-button"
        "--remove-tabsearch-button"
      ];

      dictionaries = [
        pkgs.hunspellDictsChromium.en_US
      ];

      extensions = [
        { id = "ocaahdebbfolfmndjeplogmgcagdmblk"; } # chromium web store
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
        { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
      ];
    };
  };
}
