{ pkgs, var, config, ... }: with pkgs; {
  services.udev.extraRules = ''
    SUBSYSTEM=="input", KERNEL=="js[0-9]*", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="amx.service"
  '';
  systemd.user.services.amx = {
    description = "AntiMicroX";
    bindsTo = [ "dev-input-js0.device" ];
    script = ''
      ${antimicrox}/bin/antimicrox --tray --profile ${./xboxone.amgp}
    '';
  };
}
