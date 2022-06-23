{ config, pkgs, lib, var, ... }:
with pkgs;
with lib; {
  powersave.enable = mkDefault false;
  nvidia.enable = mkDefault true;

  specialisation = {
    power-save.configuration = {
      boot.loader.grub.configurationName = "Power Save";
      powersave.enable = true;
      nvidia.enable = false;
    };
  };
}
