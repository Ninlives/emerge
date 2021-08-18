{ config, pkgs, ... }:
with pkgs;
let
  repo = fetchFromGitHub {
    owner = "Ninlives";
    repo = "pam-remote-otp";
    rev = "d2359a799ca84c120fd041c3484388e871762d35";
    sha256 = "1wbxqy286zc72iasz5zsrykg4zah6g00yhvch82hxmi8q0994hpy";
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
