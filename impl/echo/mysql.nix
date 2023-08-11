{ config, pkgs, ... }: 
let
  inherit (config.lib.path) persistent;
in
{
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;
  services.mysql.dataDir = "${persistent.data}/mysql"; 
  systemd.tmpfiles.rules = with config.users; [
    "d ${config.services.mysql.dataDir} 0700 ${users.mysql.name} ${groups.mysql.name} -"
  ];
}
