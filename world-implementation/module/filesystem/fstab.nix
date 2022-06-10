{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "nvme" "usb_storage" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "mode=0755" ];
  };

  fileSystems."/nix" = {
    device = "tower/circle/nix";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  fileSystems."/chest" = {
    device = "tower/circle/chest";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/space" = {
    device = "tower/circle/space";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/space/Windows" = {
    device = "/dev/disk/by-label/windows";
    fsType = "ntfs";
    options = [ "dmask=022" "fmask=133" ];
  };

  boot.supportedFilesystems = [ "ntfs" ];

  swapDevices = [ ];

  nix.settings.max-jobs = lib.mkDefault 12;
  # High-DPI console
  console.font =
    lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
  boot.loader.grub.device = "nodev";
}
