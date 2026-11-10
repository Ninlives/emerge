{ config, ... }:
let
  inherit (config.profile) disk;
  btrfsOpts = [
    "noatime"
    "lazytime"
    "space_cache=v2"
    "compress=zstd"
  ];
in
{
  boot.initrd.supportedFilesystems = [ "btrfs" ];
  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = ["mode=0755" "defaults" "size=75%"];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/NIX";
    fsType = "btrfs";
    options = btrfsOpts;
  };

  fileSystems."/${disk.persist}" = {
    device = "/dev/disk/by-label/${disk.persist}";
    fsType = "btrfs";
    options = btrfsOpts;
  };
}
