{ config, lib, pkgs, inputs, var, ... }:
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
    options =
      btrfsOptions (config.workspace.chestVolume) [ "compress-force=zstd" ];
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

  boot.initrd.kernelModules = [ "uinput" "evdev" "hid_steam" ];
  boot.initrd.postDeviceCommands = 
  let
    deckbd = "${inputs.deckbd.packages.${var.system}.default}/bin/deckbd";
  in
  ''
    try=10
    while true;do
      ${deckbd} query && break
      if test $try -le 0;then break; fi
      sleep 1
      echo $try Waiting for controller to appear...
      try=$((try - 1))
    done
    echo Run deckbd
    ${deckbd} &
    deckbd_pid=$!
    echo PID: $deckbd_pid
    echo Reading input
    read sdpass
    echo Read sdpass: $sdpass
    kill $deckbd_pid
    sleep 10
  '';
}
