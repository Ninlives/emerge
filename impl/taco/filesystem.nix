{ ... }:
let
  device = "/dev/disk/by-partlabel/NIXOS";
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

    "/chest" = {
      inherit device fsType;
      options = [ "subvol=chest" ] ++ options;
      neededForBoot = true;
    };

    "/tmp" = {
      inherit device fsType;
      options = [ "subvol=tmp" ] ++ options;
    };
  };
  boot.tmp.cleanOnBoot = true;

  revive.specifications.system.seal = "/chest";
}
