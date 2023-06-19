{ config, ... }: 
let
  inherit (config.lib.path) persistent;
in
{
  services.postgresql.enable = true;
  services.postgresql.dataDir = "${persistent.data}/postgres"; 
  revive.specifications.system.boxes = [{
    dst = "${persistent.data}/postgres";
    user = config.users.users.postgres.name;
    group = config.users.groups.postgres.name;
  }];
}
