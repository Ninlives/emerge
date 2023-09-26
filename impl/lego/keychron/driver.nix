{ pkgs, ... }: {
  boot.kernelModules = [ "hid_apple" ];
  boot.initrd.availableKernelModules = [ "hid_apple" ];
  services.udev.packages = [ pkgs.via ];
  hardware.keyboard.qmk.enable = true;
}
