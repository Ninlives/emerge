{ pkgs, inputs, ... }: {

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
  # imports = [ "${inputs.jovian}/modules" ];
  imports = let nixpkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  in [
    "${
      nixpkgs.applyPatches {
        name = "jovian";
        src = inputs.jovian;
        patches = [
          (nixpkgs.fetchpatch {
            url =
              "https://github.com/Jovian-Experiments/Jovian-NixOS/commit/dc365da27a3119a2ba1e858c46d7a67edae1822d.patch";
            sha256 = "sha256-1167i4aYe3MvpRlDXuigGn0nvbubz9HJXCboOEv4A+M=";
          })
          (nixpkgs.fetchpatch {
            url =
              "https://github.com/Jovian-Experiments/Jovian-NixOS/commit/7b754a9c444085a78386823d8ff23097cf9b7ae3.patch";
            sha256 = "sha256-+QkuDE1OEH3AyKxXxCRVRDtEmXep4Ub0rW/gtFSuL5U=";
          })
        ];
      }
    }/modules"
  ];
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     mangohud = prev.mangohud.overrideAttrs (p: {
  #       patches = builtins.filter
  #         (pa: !(lib.hasSuffix "preload-nix-workaround.patch" pa))
  #         (p.patches or [ ]);
  #     });
  #   })
  # ];

  jovian.devices.steamdeck.enable = true;

  environment.systemPackages = with pkgs; [
    steamdeck-firmware
    jupiter-dock-updater-bin
  ];

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [
    broadcom-bt-firmware
    b43Firmware_5_1_138
    b43Firmware_6_30_163_46
    xow_dongle-firmware
    facetimehd-calibration
    facetimehd-firmware
  ];
  allowUnfreePackageNames = [
    "b43-firmware"
    "xow_dongle-firmware"
    "broadcom-bt-firmware"
    "facetimehd-calibration"
    "facetimehd-firmware"
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings.General = {
    "Privacy" = "device";
    "JustWorksRepairing" = "always";
    "Class" = "0x000100";
    "FastConnectable" = true;
  };

  hardware.pulseaudio.enable = false;
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  # };

  # hardware.opengl.driSupport32Bit = true;

  # services.fwupd.enable = true;
  # boot.loader.grub.fontSize = 72;

  hardware.xpadneo.enable = true;
  # hardware.steam-hardware.enable = true;

  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT1 = 80;
      STOP_CHARGE_THRESH_BAT1 = 85;
    };
  };
}
