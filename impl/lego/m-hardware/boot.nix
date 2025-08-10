{ ... }: {
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.timeout = 65535;
  boot.bootspec.enable = true;
  boot.tmp.cleanOnBoot = true;
}
