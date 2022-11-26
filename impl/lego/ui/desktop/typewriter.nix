{ lib, pkgs, fn, var, ... }:
{
  specialisation.typewriter.configuration = {
      disabledModules = [
        ./gnome.nix
        ./common-gui.nix
        ../../hardware/virtualisation.nix
        ../../service/xbox-controller.nix
        ../../service/samba.nix
        ../../network/syncthing.nix
      ];
      boot.loader.grub.configurationName = "Typewriter";
      services.kmscon = {
        enable = true;
        extraConfig = ''
          font-size=30
        '';
      };
    };
}
