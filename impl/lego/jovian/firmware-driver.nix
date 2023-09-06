{
  pkgs,
  inputs,
  ...
}: {
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci"];
  boot.kernelModules = ["kvm-amd"];
  imports = ["${inputs.jovian}/modules"];

  jovian.devices.steamdeck = {
    enable = true;
    enableDefaultCmdlineConfig = false;
  };

  environment.systemPackages = with pkgs; [
    steamdeck-firmware
    jupiter-dock-updater-bin
  ];

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [
    broadcom-bt-firmware
    b43Firmware_5_1_138
    b43Firmware_6_30_163_46
    xow_dongle-firmware
    facetimehd-calibration
    facetimehd-firmware
  ];
  allowUnfreePackageNames = [
    "b43-firmware"
    "xow_dongle-firmware"
    "broadcom-bt-firmware"
    "facetimehd-calibration"
    "facetimehd-firmware"
  ];
  hardware.pulseaudio.enable = false;
  services.pipewire.alsa.support32Bit = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings.General = {
    "Privacy" = "device";
    "JustWorksRepairing" = "always";
    "Class" = "0x000100";
    "FastConnectable" = true;
  };

  hardware.xpadneo.enable = true;
  services.joycond.enable = true;

  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT1 = 80;
      STOP_CHARGE_THRESH_BAT1 = 85;
    };
  };

  revive.specifications.system.boxes = [
    {
      src = /Data/network-connections;
      dst = /etc/NetworkManager/system-connections;
    }
    {
      src = /Data/bluetooth;
      dst = /var/lib/bluetooth;
    }
  ];
}
