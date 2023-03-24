{ config, lib, pkgs, inputs, var, ... }:
let
  inherit (config.workspace) disk;
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
    options = [ "mode=0755" "defaults" ];
  };

  fileSystems."/boot" = {
    # device = "/dev/disk/by-uuid/B9C5-5EAF";
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    # device = "/dev/disk/by-uuid/ddc3d53f-f0ff-475e-a33b-a9e65ba23fc6";
    device = "/dev/mapper/store";
    fsType = "btrfs";
    options = btrfsOpts;
  };

  fileSystems."/${disk.persist}" = {
    # device = "/dev/disk/by-uuid/ddc3d53f-f0ff-475e-a33b-a9e65ba23fc6";
    device = "/dev/mapper/${disk.persist}";
    fsType = "btrfs";
    options = btrfsOpts;
  };

  swapDevices = [{ device = "/dev/mapper/${disk.swap}"; }];

  boot.initrd.luks.devices = lib.listToAttrs (map (dev: {
    name = dev;
    value = {
      device = "/dev/tower/${dev}";
      preLVM = false;
    };
  }) [ "store" disk.persist disk.swap ]);

  boot.initrd.kernelModules = [ "uinput" "evdev" "hid_steam" ];
  boot.initrd.preLVMCommands =
    let deckbd = "${inputs.deckbd.packages.${var.system}.default}/bin/deckbd";
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

  boot.supportedFilesystems = [ "ntfs" ];

  nix.settings.max-jobs = lib.mkDefault 12;
}
