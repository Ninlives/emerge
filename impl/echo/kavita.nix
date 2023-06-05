{ config, pkgs, ... }: with pkgs;
let
  dp = config.secrets.decrypted;
  domain = "${dp.kavita.subdomain}.${dp.host}";
in {
  systemd.services.kavita = {
    description = "Kavita";
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      if [[ ! -s $STATE_DIRECTORY/config/appsettings.json ]];then
        mkdir -p $STATE_DIRECTORY/config
        cat ${kavita.server}/lib/Kavita/config/appsettings.json > $STATE_DIRECTORY/config/appsettings.json
      fi
      ln -snf ${kavita.ui} $STATE_DIRECTORY/wwwroot
    '';
    script = "${kavita.server}/bin/Kavita";
    serviceConfig = {
      User = "kavita";
      Group = "kavita";
      StateDirectory = "kavita";
      WorkingDirectory = "%S/kavita";
      Restart = "on-failure"; 
    };
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:5000";
      proxyWebsockets = true;
    };
  };
  
  revive.specifications.system.boxes = [{
    src = /Services/kavita;
    dst = /var/lib/kavita/config;
    user = config.users.users.kavita.name;
    group = config.users.groups.kavita.name;
  }];
}
