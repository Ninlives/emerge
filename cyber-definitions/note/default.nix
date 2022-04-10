{ config, inputs, system, pkgs, ... }:
let
  inherit (pkgs) inotify-tools;
  dp = config.secrets.decrypted;
  user = config.users.users.note.name;
  group = config.users.groups.note.name;
  emanote = inputs.emanote.defaultPackage.${system};
  stateDir = "note";
  rootDir = "/var/lib/${stateDir}";
  bookDir = "${rootDir}/book";
  siteDir = "${rootDir}/site";
in {
  users.groups.note = { };
  users.users.note = {
    inherit group;
    isSystemUser = true;
  };

  systemd.services.emanote = {
    wantedBy = [ "multi-user.target" ];
    script = ''
      mkdir -p ${bookDir}
      chmod g+w ${bookDir}
      mkdir -p ${siteDir}

      cd ${bookDir}
      ${emanote}/bin/emanote gen ${siteDir}

      while ${inotify-tools}/bin/inotifywait -r --exclude '\.syncthing' -e modify -e create -e move -e delete ${bookDir};do
        ${emanote}/bin/emanote gen ${siteDir}
        sleep 10
      done
    '';
    serviceConfig = {
      User = user;
      Group = group;
      WorkingDirectory = rootDir;
      StateDirectory = stateDir;
      StateDirectoryMode = "2770";
      Restart = "always";
    };
  };

  services.nginx.virtualHosts.${dp.note.host} = {
    forceSSL = true;
    enableACME = true;
    locations."/".root = siteDir;
  };
  users.users.nginx.extraGroups = [ group ];

  users.users.syncthing.extraGroups = [ group ];
  services.syncthing.folders.note = {
    path = bookDir;
    devices = [ "local" ];
  };

}
