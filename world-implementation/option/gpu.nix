{ config, pkgs, lib, ... }:
let
  inherit (pkgs) writeShellScriptBin xorg cudatoolkit;
  inherit (lib) mkIf mkMerge mkOption types;
in {
  options.nvidia.asPrimaryGPU = mkOption {
    type = types.bool;
    default = true;
  };
  config = mkMerge [
    {
      hardware.nvidia.prime.nvidiaBusId = "PCI:1:0:0";
      hardware.nvidia.prime.intelBusId = "PCI:0:2:0";
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia.modesetting.enable = true;
    }

    (mkIf (!config.nvidia.asPrimaryGPU) {
      hardware.nvidia.prime.offload.enable = true;
      hardware.nvidia.powerManagement.enable = true;
      environment.systemPackages = [
        (writeShellScriptBin "nvidia-offload" ''
          export __NV_PRIME_RENDER_OFFLOAD=1
          export __GLX_VENDOR_LIBRARY_NAME=nvidia
          exec $@
        '')
      ];

      boot.extraModprobeConfig = ''
        options nvidia "NVreg_DynamicPowerManagement=0x02"
      '';

      services.udev.extraRules = ''
        # <<<udevrules>>>
        # Remove NVIDIA USB xHCI Host Controller devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{remove}="1"

        # Remove NVIDIA USB Type-C UCSI devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{remove}="1"

        # Remove NVIDIA Audio devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"

        # Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
        ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
        ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"

        # Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
        ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
        ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
        # >>>udevrules<<<
      '';
    })

    (mkIf config.nvidia.asPrimaryGPU {
      hardware.nvidia.prime.sync.enable = true;
      # services.xserver.displayManager.sessionCommands = ''
      #   ${xorg.xrandr}/bin/xrandr --setprovideroutputsource modesetting NVIDIA-0
      #   ${xorg.xrandr}/bin/xrandr --auto
      # '';
      # environment.systemPackages = [ cudatoolkit ];
    })
  ];
}
