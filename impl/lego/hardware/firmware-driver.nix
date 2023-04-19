{ pkgs, inputs, ... }: {

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
  # Temporary
  imports = [
    "${
      inputs.nixpkgs.legacyPackages.x86_64-linux.applyPatches {
        name = "jovian";
        src = inputs.jovian;
        patches = builtins.toFile "fhs.patch" ''
          diff --git a/modules/steam.nix b/modules/steam.nix
          index f726a8b..d1ddb11 100644
          --- a/modules/steam.nix
          +++ b/modules/steam.nix
          @@ -31,7 +31,7 @@ let
             # can't run a binary with such a capability without being Setuid
             # itself.
             steam = pkgs.steam.override {
          -    buildFHSUserEnv = pkgs.buildFHSUserEnvBubblewrap.override {
          +    buildFHSEnv = pkgs.buildFHSEnv.override {
                 bubblewrap = "''${config.security.wrapperDir}/..";
               };
             };
        '';
      }
    }/modules"
  ];
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
