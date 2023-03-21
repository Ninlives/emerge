{ pkgs, inputs, modulesPath, config, var, lib, ... }: {

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
  imports = [ "${inputs.jovian}/modules" ];
  jovian.devices.steamdeck.enable = true;

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

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings.General = {
    "Privacy" = "device";
    "JustWorksRepairing" = "always";
    "Class" = "0x000100";
    "FastConnectable" = true;
  };

  hardware.pulseaudio.enable = false;
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  # };

  # hardware.opengl.driSupport32Bit = true;

  # services.fwupd.enable = true;
  # boot.loader.grub.fontSize = 72;

  hardware.xpadneo.enable = true;
  # hardware.steam-hardware.enable = true;

  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT1 = 80;
      STOP_CHARGE_THRESH_BAT1 = 85;
    };
  };
}
