{ config, lib, pkgs, var, inputs, ... }:
let
  inherit (pkgs)
    writeShellScript writeShellScriptBin coreutils gnugrep gnused gnumake git;
  inherit (var.seal) chest;
  inherit (var.proxy) port;
  conf-file = "${inputs.data.content.smartdns}";
in {
  services.smartdns = {
    enable = true;
    settings = {
      server = [
        "1.1.1.1:53"
        "8.8.8.8:53"
        "9.9.9.9:53"
        "149.112.112.112:53"

        "114.114.114.114:53 -group cn"
        "114.114.115.115:53 -group cn"
        "119.29.29.29:53 -group cn"
        "223.5.5.5:53 -group cn"
        "223.6.6.6:53 -group cn"
      ];
      server-tls =
        [ "1.1.1.1:853" "8.8.8.8:853" "9.9.9.9:853" "149.112.112.112:853" ];
      server-https = [
        "https://cloudflare-dns.com/dns-query -group doh"
        "https://dns.quad9.net/dns-query -group doh"
      ];
      nameserver = "/.onion/doh";
      bind = "127.0.0.1:53";
      prefetch-domain = true;
      speed-check-mode = "ping,tcp:80";
      audit-enable = true;
      inherit conf-file;
    };
  };
  networking.resolvconf.useLocalResolver = true;
}
