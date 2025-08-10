{pkgs, ...}: {
  assertions = [{ assertion = pkgs.pcsclite.version == "2.3.0"; }];
  services.pcscd.enable = true;

  services.udev.packages = [pkgs.yubikey-personalization];
  systemd.packages = [pkgs.yubikey-touch-detector];
}
