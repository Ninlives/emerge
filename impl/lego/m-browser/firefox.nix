{
  config,
  pkgs,
  lib,
  ...
}: let
  userPrefValue = pref:
    with lib;
      builtins.toJSON (
        if isBool pref || isInt pref || isString pref
        then pref
        else builtins.toJSON pref
      );
  mkUserJs = prefs:
    with lib;
      concatStrings (mapAttrsToList (name: value: ''
          user_pref("${name}", ${userPrefValue value});
        '')
        prefs);
in {
  revive.specifications.user.boxes = [
    {
      src = /Programs/firefox;
      dst = "${config.profile.user.home}/.mozilla";
    }
  ];
  lib.firefox = {inherit mkUserJs;};
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-esr;
    nativeMessagingHosts.packages = with pkgs; [
      tridactyl-native
    ];
    languagePacks = ["zh-CN"];
    policies = {
      DisableFirefoxAccounts = true;
      DisableFirefoxStudies = true;
      PasswordManagerEnabled = false;
      DisablePocket = true;
      EnableTrackingProtection = true;
      ExtensionSettings = {
        "tridactyl.vim.betas@cmcaine.co.uk" = {
          installation_mode = "force_installed";
          install_url = "file://${pkgs.firefox-extra.addons.tridactyl}/share/mozilla/extensions/tridactyl.xpi";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          installation_mode = "force_installed";
          install_url = "file://${pkgs.firefox-extra.addons.bitwarden}/share/mozilla/extensions/bitwarden.xpi";
        };
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "file://${pkgs.firefox-extra.addons.ublock}/share/mozilla/extensions/uBlock.xpi";
        };
      };
    };
    preferences = {
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "xpinstall.signatures.required" = false;
    };
  };
}
