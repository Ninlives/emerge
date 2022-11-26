{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "usbhid" "uas" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "mode=0755" "defaults" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  boot.initrd.luks.devices."tower".device = "/dev/disk/by-partlabel/tower";

  fileSystems."/nix" = {
    device = "/dev/mapper/tower";
    fsType = "btrfs";
    options = [ "subvol=nix" "noatime" "compress-force=zstd" "space_cache=v2" ];
  };

  fileSystems."/chest" = {
    device = "/dev/mapper/tower";
    fsType = "btrfs";
    options = [ "subvol=chest" "noatime" "compress-force=zstd" "space_cache=v2" ];
  };

  boot.supportedFilesystems = [ "ntfs" ];

  nix.settings.max-jobs = lib.mkDefault 12;
  hardware.video.hidpi.enable = true;
  boot.loader.grub.device = "nodev";
}
