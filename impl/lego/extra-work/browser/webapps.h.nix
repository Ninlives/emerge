{pkgs, ...}: {
  home.packages = with pkgs; [
    (makeDesktopItem {
      name = "teams-pwa";
      desktopName = "Microsoft Teams";
      categories = ["Network" "InstantMessaging" "Chat"];
      icon = fetchurl {
        url = "https://github.com/IsmaelMartinez/teams-for-linux/blob/develop/build/icons/512x512.png?raw=true";
        sha256 = "sha256-xtsgbOxulrLyOeVICWm0ZvpOPGlQ9giCZX+ZdBaiafo=";
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
