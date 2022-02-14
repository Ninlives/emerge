{ pkgs, ... }:
let inherit (pkgs) wrapFirefox firefox-esr-unwrapped fetchFirefoxAddon;
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
      ];
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
    profiles.default = { };
  };

  persistent.boxes = [ ".mozilla/firefox/default" ];
}
