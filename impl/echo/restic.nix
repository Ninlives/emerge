{ config, pkgs, ... }:
let
  inherit (config.lib.path) persistent;
  scrt = config.sops.secrets;
  btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
in {
  services.restic.backups.services = {
    repository = "b2:mlatus-chest:echo";
    environmentFile = "${persistent.static}/b2/env";
    passwordFile = scrt.restic-password.path;
    pruneOpts = [ "--keep-daily 3" "--keep-weekly 2" ];
    backupPrepareCommand = ''
      ${btrfs} subvolume snapshot -r ${persistent.root} ${persistent.snapshot.root}
    '';
    paths = [ persistent.snapshot.services ];
    backupCleanupCommand = ''
      ${btrfs} subvolume delete ${persistent.snapshot.root}
    '';
  };
}
