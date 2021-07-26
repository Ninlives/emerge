{ config, pkgs, ... }:
with pkgs;
let
  repo = fetchFromGitHub {
    owner = "Ninlives";
    repo = "pam-remote-otp";
    rev = "4bf2daf3e4f9b19a89090add02ba33400241dbcf";
    sha256 = "1m1ss1apf8m06mmy60aifhj4rzi6j7yvqc2i072577rz50sz4fi1";
  };
  dp = config.secrets.decrypted;
in {
  services.uwsgi = {
    enable = true;
    plugins = [ "python3" ];
    capabilities = [ "CAP_NET_BIND_SERVICE" ];
    instance.type = "emperor";

    instance.vassals.otp = {
      type = "normal";
      module = "app:app";
      cap = "net_bind_service";
      socket = "127.0.0.1:33140";
      chdir = "${repo}/server";
      pythonPackages = p: [ p.flask nixos-cn.python-packages.yubiotp ];
    };
  };

  services.nginx.virtualHosts.${dp.o-host} = {
    enableACME = true;
    forceSSL = true;
    locations."/".extraConfig = ''
      uwsgi_pass 127.0.0.1:33140;
      include ${config.services.nginx.package}/conf/uwsgi_params;
    '';
  };
}
