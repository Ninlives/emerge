{
  lib,
  inputs,
  pkgs,
  ...
}:
with lib; let
  dp = inputs.values.secret;
in {
  allowUnfreePackageNames = ["teams"];
  profile.identity = "institute";
  profile.user.name = dp.workstation.username;
  profile.user.uid = 2048;
  profile.disk.persist = "institute";
  profile.disk.swap = "depot";
  profile.proxy.default = "v2ray-fallback";

  sops.roles = ["work"];
  networking.hostName = dp.workstation.hostname;

  services.displayManager.defaultSession = "gnome-xorg";
  environment.systemPackages = [
    # pkgs.teams
    pkgs.tigervnc
  ];

  system.activationScripts.update-ca-certs = stringAfter ["etc"] ''
    mkdir -p /etc/ssl/ca-anchors
    cat /etc/ssl/certs/ca-certificates.crt > /etc/ssl/ca-anchors/ca-certificates.crt
    rm /etc/ssl/certs/ca-certificates.crt
    rm /etc/ssl/certs/ca-bundle.crt

    for cert in $(find /etc/ssl/ca-anchors -name '*.crt');do
      cat "$cert" >> /etc/ssl/certs/ca-certificates.crt
    done
    cp /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-bundle.crt
  '';

  revive.specifications.system.boxes = [
    {
      src = /Data/ca-anchors;
      dst = /etc/ssl/ca-anchors;
    }
  ];
}
