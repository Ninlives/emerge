{ config, pkgs, lib, out-of-world, ... }:
with lib;
let
  inherit (pkgs) glib;
  inherit (pkgs.nixos-cn) intel-undervolt;
  inherit (out-of-world) dirs;
in {
  options.powersave.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkMerge [
    {
      systemd.services.power-profile = {
        wantedBy = [ "power-profiles-daemon.service" ];
        after = [ "power-profiles-daemon.service" ];
        serviceConfig.Type = "oneshot";
        script = ''
          ${glib}/bin/gdbus call --system --dest net.hadess.PowerProfiles --object-path /net/hadess/PowerProfiles --method org.freedesktop.DBus.Properties.Set 'net.hadess.PowerProfiles' 'ActiveProfile' "<'${if config.powersave.enable then "power-saver" else "performance"}'>"
        '';
      };
    }
    (mkIf (!config.powersave.enable) {
      powerManagement.cpuFreqGovernor = "performance";
    })
    (mkIf config.powersave.enable {
      powerManagement.cpuFreqGovernor = "powersave";
      services.thermald.enable = true;
      boot.kernelParams = [ "msr.allow_writes=on" ];
    })
  ];
}
