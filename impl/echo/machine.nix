{ pkgs, config, lib, var, modulesPath, ... }:
with lib; {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot = {
    loader.grub.device = "/dev/vda";
    initrd.availableKernelModules =
      [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
  };

  systemd.network.networks = {
    ethernet = {
      matchConfig.Name = [ "en*" "eth*" ];
      DHCP = "yes";
      networkConfig = {
        KeepConfiguration = "yes";
        IPv6AcceptRA = "yes";
        IPv6PrivacyExtensions = "no";
      };
    };
  };

  services.resolved.extraConfig = ''
    DNSStubListener=no
  '';

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/NIXOS";
    fsType = "btrfs";
    options =
      [ "subvol=boot" "noatime" "compress-force=zstd" "space_cache=v2" ];
  };

  services.rpcbind.enable = mkForce false;
  services.cachefilesd = {
    enable = true;
    cacheDir = "/chest/Cache/fs";
  };
  revive.specifications.system.boxes = [{ dst = /chest/Cache/fs; }];
}
