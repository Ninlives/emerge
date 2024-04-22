{
  pkgs,
  lib,
  inputs',
  ...
}: {
  systemd.user = {
    services.resign = {
      Install.WantedBy = ["graphical-session.target"];
      Unit.PartOf = ["graphical-session.target"];
      Unit.After = ["graphical-session.target"];
      Service = {
        Environment = [
          "PATH=${lib.makeBinPath [pkgs.pinentry-gnome3]}"
          "TERM=linux"
        ];
        ExecStart = "${inputs'.resign.packages.default}/bin/resign --listen /tmp/resign.ssh";
      };
    };
  };
  xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = ''
    ${lib.fileContents
      "${pkgs.gnome3.gnome-keyring}/etc/xdg/autostart/gnome-keyring-ssh.desktop"}
    Hidden=true
  '';
}
