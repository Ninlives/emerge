{ config, pkgs, ... }: 
let
  cfg = config.services.jellyfin;
in
{
  services.jellyfin = {
    enable = true;
  };
  systemd.service.jellyfin.serviceConfig.ExecStart = "${cfg.package}/bin/jellyfin --datadir '/var/lib/${StateDirectory}' --cachedir '/var/cache/${CacheDirectory}'";
  
  users.users.${cfg.user}.uid = 953;
  users.groups.${cfg.group}.gid = 953;
  revive.specifications.system.boxes = [{
    src = /Services/kavita;
    dst = /var/lib/kavita/config;
    user = config.users.users.kavita.name;
    group = config.users.groups.kavita.name;
  }];
}
