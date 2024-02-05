{ config, pkgs, inputs, ... }:
let
  token = config.sops.secrets.onecloud;
  update = pkgs.writers.writePython3 "update" { libraries = with pkgs.python3.pkgs; [requests dateutil]; } (builtins.readFile ./script.py);
in {
  sops.secrets.onecloud.owner = config.profile.user.name;
  systemd.user.services.update-reservations = {
    script = ''
      ${update} "${inputs.values.secret.workstation.host}" "${token.path}"
    '';
    startAt = "daily";
  };
}
