{ config, nixosConfig, lib, pkgs, ... }: {
  config = lib.mkIf (nixosConfig.workspace.identity == "workstation") {

    dconf.settings."system/proxy".mode = "auto";

    home.activation.updateFavoriteApps = let
      dconf = "${pkgs.dconf}/bin/dconf";
      tr = "${pkgs.coreutils}/bin/tr";
      key = "/org/gnome/shell/favorite-apps";
      dir = "${config.home.homeDirectory}/.local/share/applications";
    in with pkgs;
    lib.hm.dag.entryAfter [ "dconfSettings" ] ''
      if [[ -v DBUS_SESSION_BUS_ADDRESS ]]; then
        export DCONF_RUN="${dconf}"
      else
        export DCONF_RUN="${pkgs.dbus}/bin/dbus-run-session --dbus-daemon=${pkgs.dbus}/bin/dbus-daemon ${dconf}"
      fi

      for app in $(${findutils}/bin/find ${dir} -name '*.desktop' -exec ${coreutils}/bin/basename {} \;);do
        echo '"'"$app"'"'
      done|${coreutils}/bin/paste -sd ','| {
        read APPS
        $DCONF_RUN read ${key}|${tr} "'" '"'|${jq}/bin/jq -c ". + [$APPS]"|${tr} '"' "'"|{
          read APPS
          $DCONF_RUN write ${key} "$APPS"
        }
      }

      unset DCONF_RUN
      unset APPS
    '';

    persistent.boxes = [
      {
        src = /Data/certificates;
        dst = ".cert";
      }
      {
        src = /Data/applications;
        dst = ".local/share/applications";
      }
      {
        src = /Data/icons;
        dst = ".local/share/icons";
      }
    ];
  };
}
