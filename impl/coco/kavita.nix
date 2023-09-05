{config, ...}: let
  inherit (config.lib.path) persistent;
  scrt = config.sops.secrets;
in {
  services.kavita = {
    enable = true;
    dataDir = "${persistent.services}/kavita";
    tokenKeyFile = scrt."kavita/key".path;
    ipAdresses = ["127.0.0.1" "::1"];
  };

  sops.secrets."kavita/key" = {
    owner = "kavita";
    group = "kavita";
  };

  users.users.kavita = {
    uid = 954;
    group = "kavita";
    isSystemUser = true;
  };
  users.groups.kavita.gid = 954;
}
