{
  config,
  inputs,
  ...
}: let
  plh = config.sops.placeholder;
  dp = inputs.values.secret;
in {
  rathole = {
    enable = true;
    role = "server";
  };

  sops.templates.rathole.content = ''
    [server.services.ssh]
    token = "${plh."rathole/token/ssh"}"
    bind_addr = "0.0.0.0:${toString dp.ssh.port}"
  '';
  networking.firewall.allowedTCPPorts = [dp.ssh.port dp.rathole.port];
}
