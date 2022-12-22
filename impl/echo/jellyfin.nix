{ config, pkgs, lib, ... }: with pkgs; with lib;
let cfg = config.services.jellyfin;
  dp = config.secrets.decrypted;
  domain = "${dp.jellyfin.subdomain}.${dp.host}";
in {
  services.jellyfin = { enable = true; };
  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://127.0.0.1:8096";
    locations."/socket" = {
      proxyPass = "http://127.0.0.1:8096";
      proxyWebsockets = true;
    };
  };

  systemd.services.jellyfin.preStart = ''
    for f in $(${findutils}/bin/find /var/lib/jellyfin/plugins -maxdepth 1 -type l);do
      ${coreutils}/bin/rm $f
    done
    for f in /var/lib/jellyfin/plugins/*;do
      if [[ ! "$f" =~ "configurations" ]];then
        rm -rf "$f"
      fi
    done
    ${concatMapStringsSep "\n" (plugin: ''
      pdir=/var/lib/jellyfin/plugins/${plugin.pname}
      mkdir -p "$pdir"
      ${concatMapStringsSep "\n" (art: ''
        ${coreutils}/bin/ln -s "${plugin}/lib/${plugin.pname}/${art}" "$pdir/${art}"
      '') plugin.artifacts}
    '') (builtins.attrValues jellyfinPlugins)}
  '';

  revive.specifications.system.boxes = [
    {
      src = /Services/jellyfin;
      dst = /var/lib/jellyfin;
      user = config.users.users.kavita.name;
      group = config.users.groups.kavita.name;
    }
    {
      src = /Cache/jellyfin;
      dst = /var/cache/jellyfin;
      user = config.users.users.kavita.name;
      group = config.users.groups.kavita.name;
    }
  ];
  fileSystems."/chest/Data/jellyfin" = {
    device = "127.0.0.1:/chest/Data/jellyfin";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "fsc" ];
  };
}
