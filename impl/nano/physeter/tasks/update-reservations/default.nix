{
  config,
  pkgs,
  inputs,
  ...
}: let
  token = config.sops.secrets.onecloud;
  update = pkgs.writers.writePython3 "update" {libraries = with pkgs.python3.pkgs; [requests dateutil];} (builtins.readFile ./script.py);
in {
  systemd.services.update-reservations = {
    script = ''
      ${update} "${inputs.values.secret.workstation.host}" "${token.path}"
    '';
    startAt = "daily";
  };
}
