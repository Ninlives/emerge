{ pkgs, lib, config, ... }: with pkgs; with lib; let
  home = config.home.homeDirectory;
  script = action: pipe: /* bash */ ''
    if [[ -v DBUS_SESSION_BUS_ADDRESS ]]; then
      DCONF_DBUS_RUN_SESSION=""
    else
      DCONF_DBUS_RUN_SESSION="${dbus}/bin/dbus-run-session"
    fi

    if [[ -v DRY_RUN ]]; then
      echo $DCONF_DBUS_RUN_SESSION ${dconf}/bin/dconf ${action} /org/gnome/shell/extensions/gsconnect/ "${pipe}" ${home}/.config/gsconnect/config.ini
    else
      if [[ -f ${home}/.config/gsconnect/config.ini ]];then
        $DCONF_DBUS_RUN_SESSION ${dconf}/bin/dconf ${action} /org/gnome/shell/extensions/gsconnect/ ${pipe} ${home}/.config/gsconnect/config.ini
      fi
    fi
    unset DCONF_DBUS_RUN_SESSION
  '';
in {
  home.packages = [ gnomeExtensions.gsconnect ];
  dconf.settings."org/gnome/shell".enabled-extensions =
    [ "gsconnect@andyholmes.github.io" ];

  home.activation.gsconnectSettings = hm.dag.entryBetween [ "dconfSettings" ] [ "installPackages" ] (script "load" "<");
  systemd.user.services.gsconnect-save = {
    Unit = {
      Description = "Save gsconnect settings";
    };

    Install = { WantedBy = [ "default.target" ]; };

    Service = {
      ExecStart = "${coreutils}/bin/true";
      RemainAfterExit = true;
      ExecStop = toString (writeShellScript "save" (script "dump" ">"));
      Type = "oneshot";
    };
  };

  persistent.boxes = [
    {
      src = /Programs/gsconnect;
      dst = ".config/gsconnect";
    }
  ];

  requestNixOSConfig.gsconnect-ports = {
    networking.firewall.allowedTCPPorts = [ 22 ];
    networking.firewall.allowedTCPPortRanges = [{
      from = 1714;
      to = 1764;
    }];
    networking.firewall.allowedUDPPortRanges = [{
      from = 1714;
      to = 1764;
    }];
  };
}
