{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    steamdeck-firmware
    jupiter-dock-updater-bin
  ];

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [
    broadcom-bt-firmware
    b43Firmware_5_1_138
    b43Firmware_6_30_163_46
    xone-dongle-firmware
    facetimehd-calibration
    facetimehd-firmware
  ];
  allowUnfreePackageNames = [
    "b43-firmware"
    "xone-dongle-firmware"
    "broadcom-bt-firmware"
    "facetimehd-calibration"
    "facetimehd-firmware"
  ];
}
