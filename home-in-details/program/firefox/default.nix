{ pkgs, ... }:
let
  inherit (pkgs)
    wrapFirefox firefox-esr-unwrapped fetchFirefoxAddon tridactyl-native;
in {
  programs.firefox = {
    enable = true;
    package = wrapFirefox firefox-esr-unwrapped {
      nixExtensions = [
        (fetchFirefoxAddon {
          name = "bitwarden";
          url =
            "https://addons.mozilla.org/firefox/downloads/file/3878893/bitwarden_free_password_manager-1.55.0-an+fx.xpi";
          sha256 = "sha256-AjYybE0Dxp40egJk9SGco/Guad5D1IFzzVPgBto5M90=";
        })
        (fetchFirefoxAddon {
          name = "tridactyl";
          url =
            "https://addons.mozilla.org/firefox/downloads/file/3874829/tridactyl-1.22.0-an+fx.xpi";
          sha256 = "sha256-tTCYRiEh4jKMkRCrXbv/WTjY7M5hWuzPq9FvU9rEjY4=";
        })
      ];
      extraNativeMessagingHosts = [ tridactyl-native ];
      extraPolicies = {
        CaptivePortal = false;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisableFirefoxAccounts = true;
        FirefoxHome = {
          Pocket = false;
          Snippets = false;
        };
        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
        };
      };

      extraPrefs = ''
        // Show more ssl cert infos
        lockPref("security.identityblock.show_extended_validation", true);
      '';
    };
    profiles.default = {
      bookmarks = {
        GitHub.url = "https://github.com";
        Nixpkgs.url = "https://github.com/NixOS/nixpkgs";
        NixOS.url = "https://nixos.org";
        "NixOS Discourse".url = "https://discourse.nixos.org";
        BiliBili.url = "https://www.bilibili.com";
      };
      settings = { "browser.startup.page" = 3; };
    };
  };

  persistent.boxes = [{
    src = /Programs/firefox/profiles/default;
    dst = ".mozilla/firefox/default";
  }];
}
