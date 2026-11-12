{pkgs, ...}: {
  home.packages = with pkgs; [
    (makeDesktopItem {
      name = "teams-pwa";
      desktopName = "Microsoft Teams";
      categories = ["Network" "InstantMessaging" "Chat"];
      icon = fetchurl {
        url = "https://statics.teams.cdn.office.net/hashed/favicon/prod/favicon-512x512-8d51633.png";
        sha256 = "sha256-yUD/fwH5oegOXhJ+nnclZHJiOVXI+dCdmrAj6USovbI=";
      };
      exec = ''${chromium}/bin/chromium --app="https://teams.microsoft.com" %U'';
    })
  ];
  dconf.settings = {
    "org/gnome/shell".favorite-apps = ["teams-pwa.desktop"];
  };
  persistent.boxes = [
    {
      src = /Programs/chromium;
      dst = ".config/chromium";
    }
  ];
}
