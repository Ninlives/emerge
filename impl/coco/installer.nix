{ config, pkgs, modulesPath, lib, inputs, var, ... }:
with lib;
let
  installer-config = {
    imports = [
      (modulesPath + "/installer/cd-dvd/iso-image.nix")
      (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ];
    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      supportedFilesystems =
        mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
    };
    isoImage.volumeID = "INSTALLER";

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "coco-bootstrap" ''
        set -x
        set -e
        sfdisk /dev/nvme0n1 <<EOT
        label: gpt
        type="BIOS boot",        name="GRUB", size=2M
        type="EFI System",       name="BOOT", size=2G, bootable
        type="Linux filesystem", name="NIXOS", size=+
        EOT

        sleep 2

        BOOT=/dev/disk/by-partlabel/BOOT
        mkfs.vfat $BOOT

        NIXOS=/dev/disk/by-partlabel/NIXOS
        mkfs.btrfs --force $NIXOS
        mkdir -p /fsroot
        mount $NIXOS /fsroot

        btrfs subvol create /fsroot/nix
        btrfs subvol create /fsroot/chest

        OPTS=compress-force=zstd,space_cache=v2
        mkdir -p /mnt/{boot,nix,chest}
        mount $BOOT /mnt/boot
        mount -o subvol=nix,$OPTS   $NIXOS /mnt/nix
        mount -o subvol=chest,$OPTS $NIXOS /mnt/chest

        mkdir -p /mnt/chest/Static/sops
        cp /iso/age.key /mnt/chest/Static/sops
        chmod 400 /mnt/chest/Static/sops/age.key
        chmod 700 /mnt/chest/Static/sops

        nixos-install --root /mnt --system "${config.system.build.toplevel}" --no-channel-copy --no-root-passwd
      '')
    ];
    system.stateVersion = "22.05";
  };
in {
  options.installer = mkOption {
    type = types.package;
    default = (inputs.nixpkgs.lib.nixosSystem {
      inherit (var) system;
      modules = [ installer-config ];
    }).config.system.build.isoImage;
  };
}
