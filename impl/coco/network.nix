{ config, var, pkgs, ... }:
let
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  dp = config.secrets.decrypted;
  scrt = config.sops.secrets;
in {
  networking.networkmanager.enable = true;
  services.openssh.listenAddresses = [{ addr = "127.0.0.1"; inherit (dp.ssh) port; }];

  rathole = {
    enable = true;
    role = "client";
  };
  sops.templates.rathole.content = ''
    [client.services.ssh]
    token = "${plh."rathole/token/ssh"}"
    local_addr = "127.0.0.1:${toString dp.ssh.port}"
  '';
}
