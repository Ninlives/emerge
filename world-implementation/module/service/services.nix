{ config, pkgs, constant, ... }:
let
  inherit (pkgs) flameshot qt5 writeShellScript writeText xboxdrv;
in {
  systemd.services = {
    xbox-controller = let
      xbox-config = writeText "conf" ''
        [xboxdrv]
        silent = true
        device-name = "Xbox 360 Wireless Receiver"
        mimic-xpad = true
        deadzone = 4000

        [xboxdrv-daemon]
        dbus = disabled
      '';
    in {
      description = "Xbox controller driver daemon";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "forking";
        PIDFile = "/run/xboxdrv.pid";
        ExecStart =
          "${xboxdrv}/bin/xboxdrv --daemon --detach --pid-file /run/xboxdrv.pid -c ${xbox-config} --detach-kernel-driver --deadzone 4000 --deadzone-trigger 10%";
      };
    };
  };
}
