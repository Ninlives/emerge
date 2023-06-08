{ pkgs, fn, var, lib, ... }: {
  imports =
    [ ./network.nix ./immich.nix ./installer.nix ./jellyfin.nix ./kavita.nix ]
    ++ (fn.dotNixFrom ../taco);

  services.logind.lidSwitch = "ignore";

  hardware.enableRedistributableFirmware = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "nvidia-x11" "nvidia-settings" ];
  hardware.opengl.enable = true;

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "nvme" "usb_storage" "uas" "sd_mod" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    efiSupport = true;
  };
  console.font = "ter-i32b";
  console.packages = [ pkgs.terminus_font ];
  console.earlySetup = true;

  users.users.mlatus.extraGroups = var.user.groups;

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/BOOT";
    fsType = "vfat";
  };
}
