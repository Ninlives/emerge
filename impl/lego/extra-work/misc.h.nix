{
  pkgs,
  inputs,
  ...
}: {
  dconf.settings = {
    "system/proxy".mode = "auto";
    "org/gnome/desktop/background".picture-uri = "file://${inputs.data.content.resources "wallpapers/jez.jpg"}";
    "org/gnome/desktop/background".picture-uri-dark = "file://${inputs.data.content.resources "wallpapers/jez.jpg"}";
  };

  home.packages = [pkgs.pomodoro pkgs.cool-retro-term];

  persistent.boxes = [
    {
      src = /Data/certificates;
      dst = ".cert";
    }
    {
      src = /Programs/gnome-pomodoro;
      dst = ".local/share/gnome-pomodoro";
    }
    {
      src = /Programs/cool-retro-term;
      dst = ".local/share/cool-retro-term/cool-retro-term";
    }
  ];
}
