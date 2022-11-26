
{ config, ... }:
let
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  scrt = config.sops.secrets;
in
{
  services.restic.backups.services = {
    repository = "b2:mlatus-chest:echo";
    environmentFile = tpl.restic.path;
    passwordFile = scrt.restic-passwd.path;
    pruneOpts = [
      "--keep-daily 3"
      "--keep-weekly 2"
    ];
    paths = [ "/chest/Services" ];
  };
  sops.templates.restic.content = ''
    B2_ACCOUNT_ID=${plh."api-key/b2/id"}
    B2_ACCOUNT_KEY=${plh."api-key/b2/key"}
  '';
}
