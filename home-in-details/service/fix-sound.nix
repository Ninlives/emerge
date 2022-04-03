{ pkgs, config, nixosConfig, ... }:
let
  inherit (pkgs) writeShellScript dbus;
  fixSoundScript =
    let pactl = "${nixosConfig.hardware.pulseaudio.package}/bin/pactl";
    in writeShellScript "fix" ''
      ${pactl} set-sink-port 3 '[Out] Speaker'
      ${pactl} set-default-sink 3
      ${pactl} set-sink-volume 3 70%

      ${pactl} set-source-port 5 '[In] Mic1'
      ${pactl} set-default-source 5
    '';
in {
  systemd.user.services.fix-sound = {
    Unit = {
      Description = "Fix sound";
      After = [ "pulseaudio.service" ];
    };

    Install = { WantedBy = [ "pulseaudio.service" ]; };

    Service = {
      ExecStart = "${fixSoundScript}";
      Restart = "on-failure";
      Type = "oneshot";
    };
  };
}
