{ pkgs, inputs, modulesPath, config, var, lib, ... }: {

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
  imports = [ "${inputs.jovian}/modules" ];
  jovian.devices.steamdeck.enable = true;

  hardware.uinput.enable = true;
  users.users.opensd = {
    isSystemUser = true;
    home = "/var/lib/opensd";
    createHome = true;
    group = config.users.groups.opensd.name;
  };
  users.groups.opensd = { };
  services.udev.packages = [ pkgs.opensd ];
  systemd.services.opensd = with lib.generators;
    let
      cfgRoot = "/var/lib/opensd/.config/opensd";
      mkKeyValue = mkKeyValueDefault { } " = ";
      cfgINI = builtins.toFile "config.ini"
        (toINI { inherit mkKeyValue; } { Daemon.Profile = "default.profile"; });
      prfl = builtins.toFile "default.profile" (toINI { inherit mkKeyValue; } {
        Profile.Name = "Keyboard";
        Features.MouseDevice = true;
        Bindings = {
          DpadUp = "Mouse KEY_1";
          DpadLeft = "Mouse KEY_2";
          DpadDown = "Mouse KEY_3";
          DpadRight = "Mouse KEY_4";
          Y = "Mouse KEY_5";
          X = "Mouse KEY_6";
          A = "Mouse KEY_7";
          B = "Mouse KEY_8";
          L1 = "Mouse KEY_9";
          R1 = "Mouse KEY_0";
          L2 = "Mouse KEY_BACKSPACE";
          R2 = "Mouse KEY_ENTER";
        };
      });
    in {
      wantedBy = [ "multi-user.target" ];
      script = ''
        exec ${pkgs.opensd}/bin/opensdd -l info
      '';
      preStart = ''
        mkdir -p ${cfgRoot}/profiles
        rm -f ${cfgRoot}/config.ini
        rm -f ${cfgRoot}/profiles/default.profile
        ln -s ${cfgINI} ${cfgRoot}/config.ini
        ln -s ${prfl} ${cfgRoot}/profiles/default.profile
      '';
      serviceConfig = with config.users; {
        User = users.opensd.name;
        SupplementaryGroups = [ groups.uinput.name groups.input.name ];
      };
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
}
