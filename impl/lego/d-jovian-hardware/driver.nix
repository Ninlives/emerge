{inputs, config, ...}: {
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci"];
  boot.kernelModules = ["kvm-amd"];
  imports = [inputs.jovian.nixosModules.default];

  jovian.devices.steamdeck = {
    enable = true;
    enableDefaultCmdlineConfig = false;
  };
  jovian.steamos.enableBluetoothConfig = true;
  allowUnfreePackageNames = [ "steam-jupiter-unwrapped" ];

  services.joycond.enable = true;

  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT1 = 80;
      STOP_CHARGE_THRESH_BAT1 = 85;
    };
  };
}
