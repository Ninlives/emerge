{ pkgs, inputs, modulesPath, config, ... }: {

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
  imports = [ "${inputs.jovian}/modules" ];
  jovian.devices.steamdeck.enable = true;

  users.groups.opensd = { };
  users.users."${config.workspace.user.name}".extraGroups = [ "opensd" ];
  services.udev.packages = [ pkgs.opensd ];

  home-manager.users."${config.workspace.user.name}".systemd.user.services.opensd =
    {
      Install = { WantedBy = [ "default.target" ]; };
      Service = { ExecStart = "${pkgs.opensd}/bin/opensdd -l info"; };
    };

  environment.systemPackages = with pkgs; [
    steamdeck-firmware
    jupiter-dock-updater-bin
  ];

  hardware.enableAllFirmware = true;

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
