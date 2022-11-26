{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [ gnome-podcasts ];
  persistent.boxes = [
    {
      src = /Programs/gnome-podcasts;
      dst = ".local/share/gnome-podcasts";
    }
  ];
}
