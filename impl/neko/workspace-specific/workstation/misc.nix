{ config, nixosConfig, lib, pkgs, inputs, ... }: {
  config = lib.mkIf (nixosConfig.workspace.identity == "workstation") {

    dconf.settings = {
      "system/proxy".mode = "auto";
      "org/gnome/desktop/background".picture-uri =
        "file://${inputs.data.content.resources "wallpapers/jez.jpg"}";
      "org/gnome/desktop/background".picture-uri-dark =
        "file://${inputs.data.content.resources "wallpapers/jez.jpg"}";
    };

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
    home.packages = [ pkgs.gnome.pomodoro pkgs.cool-retro-term ];

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
      {
        src = /Programs/gnome-pomodoro;
        dst = ".local/share/gnome-pomodoro";
      }
      {
        src = /Programs/cool-retro-term;
        dst = ".local/share/cool-retro-term";
      }
    ];
  };
}
