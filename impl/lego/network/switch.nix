{ config, pkgs, lib, var, ... }:
let
  inherit (var) proxy;
  inherit (pkgs) iptables writeShellScript writeShellScriptBin gnugrep findutils;
  inherit (lib) concatMapStringsSep optionalString;

  ip46tables = writeShellScript "ip46tables" ''
    ${iptables}/bin/iptables -w "$@"
    ${
      optionalString config.networking.enableIPv6 ''
        ${iptables}/bin/ip6tables -w "$@"
      ''
    }
  '';

  tag = "V2RAY_SPEC_MLATUS";
  doNotRedirect = concatMapStringsSep "\n" (f: ''
    ${ip46tables} -t nat -A ${tag} ${f} -j RETURN 2>/dev/null || true
  '') [
    "-d 0.0.0.0/8"
    "-d 10.0.0.0/8"
    "-d 127.0.0.0/8"
    "-d 169.254.0.0/16"
    "-d 172.16.0.0/12"
    "-d 192.168.0.0/16"
    "-d 224.0.0.0/4"
    "-d 240.0.0.0/4"
  ];

  noproxy = "/${config.workspace.disk.persist}/System/Data/proxy/noproxy";
  speech = writeShellScriptBin "speech" ''
    ${ip46tables} -t nat -F ${tag} 2>/dev/null || true
    ${ip46tables} -t nat -N ${tag} 2>/dev/null || true
    
    if [[ -x ${noproxy} ]];then
      ${noproxy}|${findutils}/bin/xargs -I {} ${ip46tables} -t nat -A ${tag} -d {} -j RETURN
    else
      ${doNotRedirect}
    fi
    ${ip46tables} -t nat -A ${tag} -m mark --mark ${toString proxy.mark} -j RETURN
    ${ip46tables} -t nat -A ${tag} -m owner --gid-owner ${proxy.group}   -j RETURN

    ${ip46tables} -t nat -A ${tag} -p tcp -j REDIRECT --to-ports ${
      toString proxy.port.redir
    } 2>/dev/null || true
    ${ip46tables} -t nat -A OUTPUT -p tcp -j ${tag} 2>/dev/null || true

  '';

  speechless = writeShellScriptBin "speechless" ''
    ${iptables}/bin/iptables-save -c|${gnugrep}/bin/grep -v ${tag}|${iptables}/bin/iptables-restore -c
    ${optionalString config.networking.enableIPv6 ''
      ${iptables}/bin/ip6tables-save -c|${gnugrep}/bin/grep -v ${tag}|${iptables}/bin/ip6tables-restore -c
    ''}
  '';

in {
  environment.systemPackages = [ speech speechless ];

  security.sudo.extraRules = [{
    users = [ config.workspace.user.name ];
    commands = [
      {
        command = "${speech}/bin/speech";
        options = [ "NOPASSWD" ];
      }
      {
        command = "${speechless}/bin/speechless";
        options = [ "NOPASSWD" ];
      }
    ];
  }];
}
