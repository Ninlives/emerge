{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [ bitwarden bitwarden-cli ];
  persistent.boxes = [
    {
      src = /Programs/vaultwarden/gui;
      dst = ".config/Bitwarden";
    }
    {
      src = /Programs/vaultwarden/cli;
      dst = ".config/Bitwarden CLI";
    }
  ];
}
