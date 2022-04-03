{ pkgs, lib, config, nixosConfig, ... }:
let
  inherit (pkgs) writeShellScript glib;
  inherit (lib) mkIf;
in {
  systemd.user.services.gsettings = mkIf (!nixosConfig.powersave.enable) {
    Unit = {
      Description = "GSettings";
      After = [ "gnome-session.target" ];
    };

    Install = { WantedBy = [ "gnome-session.target" ]; };

    Service = {
      ExecStart = "${writeShellScript "gsettings" ''
        ${glib}/bin/gsettings set org.gnome.desktop.session idle-delay 0
      ''}";
      Restart = "on-failure";
      Type = "oneshot";
    };
  };
}
