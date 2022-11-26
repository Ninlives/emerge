{ config, pkgs, ... }: {
  systemd.services.disable-dgpu = {
    wantedBy = [ "local-fs.target" "suspend.target" ];
    after = [ "local-fs.target" "suspend.target" ];

    description = "Disable dGpu";
    script = ''
      echo 1 > /sys/devices/platform/asus-nb-wmi/dgpu_disable && echo Disabled Once || echo Some error in first disable
      echo 1 > /sys/bus/pci/rescan && echo Rescan || echo Some error in rescan
      echo 1 > /sys/devices/platform/asus-nb-wmi/dgpu_disable && echo Disabled Twice || echo Some error in second disable
    '';
    serviceConfig.Type = "oneshot";
  };
  services.udev.extraRules = /* udevrules */ ''
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", ATTR{remove}="1"
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", ATTR{remove}="1"
    '';

  boot.blacklistedKernelModules =
    [ "nouveau" "nvidia" "nvidia-drm" "nvidia-modeset" "i2c_nvidia_gpu" ];
}
