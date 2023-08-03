{ config, ... }: 
let
  inherit (config.lib.path) persistent;
in
{
  services.postgresql.enable = true;
  services.postgresql.dataDir = "${persistent.data}/postgres"; 
  systemd.tmpfiles.rules = with config.users; [
    "d ${config.services.postgresql.dataDir} 0700 ${users.postgres.name} ${groups.postgres.name} -"
  ];
}
