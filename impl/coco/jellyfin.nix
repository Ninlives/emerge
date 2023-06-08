{ config, pkgs, lib, ... }:
with pkgs;
with lib; {
  services.jellyfin.enable = true;

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

  users.users.jellyfin = {
    uid = 953;
    group = "jellyfin";
    isSystemUser = true;
  };
  users.groups.jellyfin.gid = 953;
  revive.specifications.system.boxes = [
    {
      src = /Services/jellyfin;
      dst = /var/lib/jellyfin;
      user = config.users.users.jellyfin.name;
      group = config.users.groups.jellyfin.name;
    }
    {
      src = /Cache/jellyfin;
      dst = /var/cache/jellyfin;
      user = config.users.users.jellyfin.name;
      group = config.users.groups.jellyfin.name;
    }
  ];
}
