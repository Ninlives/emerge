{ ... }: {
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.timeout = 65535;
  boot.tmp.cleanOnBoot = true;
}
