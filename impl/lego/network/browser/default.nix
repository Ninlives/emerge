{ config, pkgs, lib, inputs, ... }:
let
  dp = inputs.values.secret;
  syncserver = dp.host.private.services.syncstorage.fqdn;
  userPrefValue = pref:
    with lib;
    builtins.toJSON (if isBool pref || isInt pref || isString pref then
      pref
    else
      builtins.toJSON pref);
  mkUserJs = prefs:
    with lib;
    concatStrings (mapAttrsToList (name: value: ''
      user_pref("${name}", ${userPrefValue value});
    '') prefs);
in {
  revive.specifications.user.boxes = [{
    src = /Programs/firefox;
    dst = "${config.workspace.user.home}/.mozilla";
  }];
  lib.firefox = { inherit mkUserJs; };
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-esr;
    nativeMessagingHosts = {
      gsconnect = true;
      tridactyl = true;
    };
    languagePacks = [ "zh-CN" ];
    policies = {
      DisableFirefoxStudies = true;
      PasswordManagerEnabled = false;
      DisablePocket = true;
      EnableTrackingProtection = true;
      ExtensionSettings = {
        "tridactyl.vim.betas@cmcaine.co.uk" = {
          installation_mode = "force_installed";
          install_url =
            "file://${pkgs.firefox-extra.addons.tridactyl}/share/mozilla/extensions/tridactyl.xpi";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          installation_mode = "force_installed";
          install_url =
            "file://${pkgs.firefox-extra.addons.bitwarden}/share/mozilla/extensions/bitwarden.xpi";
        };
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url =
            "file://${pkgs.firefox-extra.addons.ublock}/share/mozilla/extensions/uBlock.xpi";
        };
      };
    };
    preferences = {
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "xpinstall.signatures.required" = false;
    };
  };

  home-manager.users.${config.workspace.user.name} = { ... }: {
    home.file.".config/tridactyl/tridactylrc".source = ./tridactylrc;
    home.file.".mozilla/firefox/profiles.ini".text = lib.generators.toINI { } {
      Profile0 = {
        Name = "zero";
        Path = "zero";
        IsRelative = 1;
        Default = 1;
      };
      General.StartWithLastProfile = 1;
    };
    home.file.".mozilla/firefox/zero/user.js".text = mkUserJs {
      "browser.startup.page" = 3;
      "identity.sync.tokenserver.uri" = "https://${syncserver}/1.0/sync/1.5";
    };
    home.file.".mozilla/firefox/zero/chrome/userChrome.css".source =
      "${pkgs.firefox-extra.csshacks}/chrome/autohide_bookmarks_and_main_toolbars.css";
  };
}
