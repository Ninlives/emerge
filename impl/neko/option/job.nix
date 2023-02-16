{ lib, pkgs, config, ... }:
with lib;
with lib.types; {
  options.job = {
    cleanup = mkOption {
      type = lines;
      default = "${pkgs.coreutils}/bin/true";
    };
  };

  config = {
    systemd.user.services.job = {
      Unit = { Description = "Various jobs."; };

      Install = { WantedBy = [ "default.target" ]; };

      Service = {
        ExecStart = "${pkgs.coreutils}/bin/true";
        RemainAfterExit = true;
        ExecStop = "${pkgs.writeShellScript "cleanup" config.job.cleanup}";
        Type = "oneshot";
      };
    };
  };
}
