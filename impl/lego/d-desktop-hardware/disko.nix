{ config, ... }:
let
  btrfsOpts = [
    "noatime"
    "lazytime"
    "space_cache=v2"
    "autodefrag"
    "ssd_spread"
    "compress-force=zstd"
  ];
in
{
  disko.devices = {
    disk.main = {
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          GRUB = {
            priority = 1;
            size = "1M";
            type = "EF02";
          };
          BOOT = {
            priority = 2;
            size = "2G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          OS = {
            size = "100%";
            content = {
              type = "btrfs";
              subvolumes = {
                "/${config.profile.disk.persist}" = {
                  mountpoint = "/${config.profile.disk.persist}";
                  mountOptions = btrfsOpts;
                };
                "/store" = {
                  mountpoint = "/nix";
                  mountOptions = btrfsOpts;
                };
              };
            };
          };
        };
      };
    };
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = ["mode=0755" "defaults" "size=75%"];
    };
  };
}
