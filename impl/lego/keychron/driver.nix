{pkgs, ...}: {
  boot.initrd.availableKernelModules = ["dwc3_pci"];
  services.udev.packages = [pkgs.via];
  hardware.keyboard.qmk.enable = true;
}
