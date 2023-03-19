{ config, pkgs, lib, ... }: {

  system.nixos.tags = [ config.boot.kernelPackages.kernel.version ];
  system.nixos.label = with lib;
    concatStringsSep "-" ([ config.specialisation-name ]
      ++ (sort (x: y: x < y) config.system.nixos.tags));

  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.bootspec.enable = true;
  boot.loader.systemd-boot.enable = false;
  boot.loader.timeout = 65535;

  boot.loader.systemd-boot.consoleMode = "auto";
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  sops.secrets."secureboot/GUID".mode = "0444";
  environment.etc = with lib;
    (listToAttrs (map (file: {
      name = file;
      value.source = config.sops.secrets.${file}.path;
    }) [
      "secureboot/GUID"
      "secureboot/keys/db/db.key"
      "secureboot/keys/db/db.pem"
      "secureboot/keys/KEK/KEK.key"
      "secureboot/keys/KEK/KEK.pem"
      "secureboot/keys/PK/PK.key"
      "secureboot/keys/PK/PK.pem"
    ]));
  environment.systemPackages = [ pkgs.sbctl ];

  boot.cleanTmpDir = true;

  revive.specifications.system.boxes = [
    {
      src = /Log;
      dst = /var/log;
    }
    {
      src = /Cache/fwupd;
      dst = /var/cache/fwupd;
    }
    {
      src = /Data/fwupd;
      dst = /var/lib/fwupd;
    }
  ];
}
