{pkgs, ...}: {
  home.packages = with pkgs; [
    (makeDesktopItem {
      name = "teams-for-linux";
      desktopName = "Microsoft Teams";
      categories = ["Network" "InstantMessaging" "Chat"];
      icon = fetchurl {
        url = "https://github.com/IsmaelMartinez/teams-for-linux/blob/develop/build/icons/512x512.png?raw=true";
        sha256 = "sha256-xtsgbOxulrLyOeVICWm0ZvpOPGlQ9giCZX+ZdBaiafo=";
      };
      exec = ''${chromium}/bin/chromium --app="https://teams.microsoft.com" %U'';
    })
  ];
  persistent.boxes = [
    {
      src = /Programs/chromium;
      dst = ".config/chromium";
    }
  ];
}
