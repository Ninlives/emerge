{ pkgs, ... }:
let inherit (pkgs) writeShellScript glib;
in {
  systemd.user.services.gsettings = {
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
