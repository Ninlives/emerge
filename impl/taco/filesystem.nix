{ config, ... }:
let
  inherit (config.lib.path) persistent;
  device = "/dev/disk/by-partlabel/${persistent.label}";
  fsType = "btrfs";
  options = [ "noatime" "compress-force=zstd" "space_cache=v2" ];
in
{
  fileSystems = {
    "/" = {
      fsType = "tmpfs";
      options = [ "defaults" "mode=755" ];
    };

    "/nix" = {
      inherit device fsType;
      options = [ "subvol=nix" ] ++ options;
    };

    ${persistent.root} = {
      inherit device fsType;
      options = [ "subvol=${persistent.volume}" ] ++ options;
      neededForBoot = true;
    };

    "/tmp" = {
      inherit device fsType;
      options = [ "subvol=tmp" ] ++ options;
    };
  };
  boot.tmp.cleanOnBoot = true;

  revive.specifications.system = {
    seal = persistent.root;
    mode = "0755";
  };
}
