{ ... }: {

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
  };
}
