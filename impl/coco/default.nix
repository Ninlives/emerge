{ pkgs, fn, var, ... }: {
  imports = [ ./network.nix ./immich.nix ./installer.nix ./nfs.nix ]
    ++ (fn.dotNixFrom ../taco);

  services.logind.lidSwitch = "ignore";

  hardware.enableAllFirmware = true;
  hardware.video.hidpi.enable = true;
  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "nvme" "usb_storage" "uas" "sd_mod" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    efiSupport = true;
  };
  console.font = "ter-i32b";
  console.packages = [ pkgs.terminus_font ];
  console.earlySetup = true;

  users.users.${var.user.name}.extraGroups = var.user.groups;

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/BOOT";
    fsType = "vfat";
  };

  services.kmscon = {
    enable = true;
    extraConfig = ''
      font-size=30
    '';
  };
}
