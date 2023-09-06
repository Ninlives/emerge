{
  config,
  lib,
  inputs',
  ...
}: let
  inherit (config.profile) disk;
  btrfsOpts = [
    "noatime"
    "lazytime"
    "space_cache=v2"
    "autodefrag"
    "ssd_spread"
    "compress-force=zstd"
  ];
in {
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
    device = "/dev/mapper/store";
    fsType = "btrfs";
    options = btrfsOpts;
  };

  fileSystems."/${disk.persist}" = {
    device = "/dev/mapper/${disk.persist}";
    fsType = "btrfs";
    options = btrfsOpts;
  };

  fileSystems."/plateau" = {
    device = "/dev/mapper/plateau";
    fsType = "btrfs";
    options = btrfsOpts;
  };

  fileSystems."/tavern" = {
    device = "/dev/disk/by-label/tavern";
    fsType = "ext4";
    options = ["x-systemd.automount" "noauto"];
  };

  swapDevices = [{device = "/dev/mapper/${disk.swap}";}];

  boot.initrd.luks.devices = lib.listToAttrs (map (dev: {
    name = dev;
    value = {
      device = "/dev/tower/${dev}";
      preLVM = false;
    };
  }) ["store" "plateau" disk.persist disk.swap]);

  boot.initrd.kernelModules = ["uinput" "evdev" "hid_steam"];
  boot.initrd.preLVMCommands = let
    deckbd = "${inputs'.deckbd.packages.default}/bin/deckbd";
  in ''
    try=10
    while true;do
      ${deckbd} query && break
      if test $try -le 0;then break; fi
      sleep 1
      echo "Waiting for controller to appear, $try retry remains..."
      try=$((try - 1))
    done
    echo "Initialise deckbd";
    ${deckbd} &
    DECKBD_PID=$!
  '';
  boot.initrd.postMountCommands = ''
    kill $DECKBD_PID
  '';

  boot.supportedFilesystems = ["ntfs"];

  nix.settings.max-jobs = lib.mkDefault 12;
}
