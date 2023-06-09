{ pkgs, ... }: {
  services.pcscd.enable = true;

  services.udev.packages = [ pkgs.yubikey-personalization ];
  systemd.packages = [ pkgs.yubikey-touch-detector ];
}
