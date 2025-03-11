{inputs, config, ...}: {
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci"];
  boot.extraModulePackages = [ config.boot.kernelPackages.evdi ];
  boot.kernelModules = ["kvm-amd" "evdi"];
  imports = [inputs.jovian.nixosModules.default];

  jovian.devices.steamdeck = {
    enable = true;
    enableDefaultCmdlineConfig = false;
  };
  jovian.steamos.enableBluetoothConfig = true;
  allowUnfreePackageNames = [ "steam-jupiter-unwrapped" ];

  services.pulseaudio.enable = false;
  services.pipewire.alsa.support32Bit = true;

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
