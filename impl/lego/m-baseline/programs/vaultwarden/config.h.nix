{pkgs, ...}: {
  home.packages = [pkgs.bitwarden-desktop pkgs.bitwarden-cli-wrapper];
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
