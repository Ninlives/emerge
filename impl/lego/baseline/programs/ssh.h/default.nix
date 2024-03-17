{
  pkgs,
  lib,
  inputs',
  ...
}: {
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/resign.ssh";
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
        ExecStart = "${inputs'.resign.packages.default}/bin/resign --listen %t/resign.ssh";
      };
    };
  };
  xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = ''
    ${lib.fileContents
      "${pkgs.gnome3.gnome-keyring}/etc/xdg/autostart/gnome-keyring-ssh.desktop"}
    Hidden=true
  '';
}
