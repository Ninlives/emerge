{pkgs, ...}: {
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci"];
  boot.kernelModules = ["kvm-amd" "btintel"];
  hardware.graphics.extraPackages = [pkgs.libvdpau-va-gl pkgs.libva-vdpau-driver];

  services.ratbagd.enable = true;
}
