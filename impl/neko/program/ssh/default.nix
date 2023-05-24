{ pkgs, lib, var, inputs, ... }: {
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/resign.ssh";
  requestNixOSConfig.wtf-gnome.services.gnome.gnome-keyring.enable = lib.mkForce false;
  systemd.user = {
    services.resign = {
      Install.WantedBy = [ "graphical-session.target" ];
      Unit.PartOf = [ "graphical-session.target" ];
      Unit.After = [ "graphical-session.target" ];
      Service = {
        Environment = [
          "PATH=${lib.makeBinPath [ pkgs.pinentry-gnome ]}"
          "TERM=linux"
        ];
        ExecStart = "${inputs.resign.packages.${var.system}.default}/bin/resign --listen %t/resign.ssh";
      };
    };
  };
}
