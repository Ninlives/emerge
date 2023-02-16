{ config, lib, pkgs, ... }:
let
  btrfsOptions = volume: extraOptions:
    [
      "subvol=${volume}"
      "noatime"
      "lazytime"
      "space_cache=v2"
      "autodefrag"
      "ssd_spread"
    ] ++ extraOptions;
in {
  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "mode=0755" "defaults" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/tower";
    fsType = "btrfs";
    options = btrfsOptions "nix" [ "compress-force=zstd" ];
  };

  fileSystems."/chest" = {
    device = "/dev/disk/by-label/tower";
    fsType = "btrfs";
    options = btrfsOptions (config.workspace.chestVolume) [ "compress-force=zstd" ];
  };

  fileSystems."/deck" = {
    device = "/dev/disk/by-label/tower";
    fsType = "btrfs";
    options = btrfsOptions "deck" [ "compress=none" ];
  };
  swapDevices = [{ device = "/deck/swap"; }];

  boot.supportedFilesystems = [ "ntfs" ];

  nix.settings.max-jobs = lib.mkDefault 12;
  hardware.video.hidpi.enable = true;
  boot.loader.grub.device = "nodev";
}
