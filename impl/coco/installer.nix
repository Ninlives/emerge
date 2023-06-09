{ config, pkgs, modulesPath, lib, inputs, var, ... }:
with lib;
let
  inherit (config.lib.path) persistent;
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
        btrfs subvol create /fsroot/${persistent.volume}
        btrfs subvol create /fsroot/tmp

        OPTS=compress-force=zstd,space_cache=v2
        mkdir -p /mnt/{boot,nix,${persistent.root}}
        mount $BOOT /mnt/boot
        mount -o subvol=nix,$OPTS   $NIXOS /mnt/nix
        mount -o subvol=${persistent.volume},$OPTS $NIXOS /mnt/${persistent.root}

        mkdir -p /mnt/${persistent.static}/sops
        cp /iso/age.key /mnt/${persistent.static}/sops
        chmod 400 /mnt/${persistent.static}/sops/age.key
        chmod 700 /mnt/${persistent.static}/sops

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
