{ pkgs, ... }:
let inherit (pkgs) bluez pulseaudioFull;
in {
  hardware.enableAllFirmware = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings.General = {
    "Privacy" = "device";
    "JustWorksRepairing" = "always";
    "Class" = "0x000100";
    "FastConnectable" = true;
  };

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.opengl.driSupport32Bit = true;

  services.fwupd.enable = true;
  boot.loader.grub.fontSize = 72;

  hardware.xpadneo.enable = true;
  hardware.steam-hardware.enable = true;
}
