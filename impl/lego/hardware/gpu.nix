{ config, pkgs, lib, ... }:
let
  inherit (pkgs) writeShellScriptBin xorg cudatoolkit;
  inherit (lib) mkIf mkMerge mkOption types;
in {
  options.nvidia = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };
  config = mkMerge [
    (mkIf config.nvidia.enable {
      hardware.nvidia.prime.nvidiaBusId = "PCI:1:0:0";
      hardware.nvidia.prime.intelBusId = "PCI:0:2:0";
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia.modesetting.enable = true;
      hardware.nvidia.prime.sync.enable = true;
      services.xserver.displayManager.sessionCommands = ''
        ${xorg.xrandr}/bin/xrandr --setprovideroutputsource modesetting NVIDIA-0
        ${xorg.xrandr}/bin/xrandr --auto
      '';
    })
    (mkIf (!config.nvidia.enable) {
      hardware.nvidiaOptimus.disable = true;
    })
  ];
}
