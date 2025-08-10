{
  pkgs,
  lib,
  nixosConfig,
  ...
}: {
  home.file.".config/tridactyl/tridactylrc".source = ./tridactylrc;
  home.file.".mozilla/firefox/profiles.ini".text = lib.generators.toINI {} {
    Profile0 = {
      Name = "zero";
      Path = "zero";
      IsRelative = 1;
      Default = 1;
    };
    General.StartWithLastProfile = 1;
  };
  home.file.".mozilla/firefox/zero/user.js".text = nixosConfig.lib.firefox.mkUserJs {
    "browser.startup.page" = 3;
  };
  home.file.".mozilla/firefox/zero/chrome/userChrome.css".source = "${pkgs.firefox-extra.csshacks}/chrome/autohide_bookmarks_and_main_toolbars.css";
}
