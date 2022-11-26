{ pkgs, lib, var, inputs, ... }: {
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/resign.ssh";
  systemd.user = {
    services.resign = {
      Install.WantedBy = [ "graphical-session.target" ];
      Unit.PartOf = [ "graphical-session.target" ];
      Unit.After = [ "graphical-session.target" ];
      Service = {
        Environment = [
          "PATH=${lib.makeBinPath [ pkgs.pinentry-gtk2 ]}"
        ];
        ExecStart = "${inputs.resign.packages.${var.system}.default}/bin/resign --listen %t/resign.ssh";
      };
    };
  };
}
