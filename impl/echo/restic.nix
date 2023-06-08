
{ config, ... }:
let
  scrt = config.sops.secrets;
in
{
  services.restic.backups.services = {
    repository = "b2:mlatus-chest:echo";
    environmentFile = "/chest/Static/b2/env";
    passwordFile = scrt.restic-passwd.path;
    pruneOpts = [
      "--keep-daily 3"
      "--keep-weekly 2"
    ];
    paths = [ "/chest/Services" ];
  };
}
