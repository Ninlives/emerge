{ config, pkgs, lib, ... }: 
let
  inherit (pkgs) zfs;
in
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = zfs.latestCompatibleLinuxPackages;

  networking.hostId = "87b331db";
  boot.zfs.requestEncryptionCredentials = true;
  boot.loader.grub.copyKernels = true;

  boot.zfs.enableUnstable = true;
  services.zfs.trim.enable = true;
  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoSnapshot.monthly = 3;
}
