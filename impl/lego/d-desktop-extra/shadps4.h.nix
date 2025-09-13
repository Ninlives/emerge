{ pkgs, ... }: {
  home.packages = [pkgs.shadps4];
  persistent.boxes = [{src = /Programs/shadPS4; dst = ".local/share/shadPS4";}];
}
