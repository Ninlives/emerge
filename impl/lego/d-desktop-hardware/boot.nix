{ inputs, ... }: {
   boot.loader.grub.enable = true;
   boot.loader.grub.efiSupport = true;
   boot.loader.grub.efiInstallAsRemovable = true;

   imports = [inputs.minegrub-theme.nixosModules.default];
   boot.loader.grub.minegrub-theme = {
     enable = true;
     splash = "I use NixOS BTW!";
     background = "background_options/1.8  - [Classic Minecraft].png";
     boot-options-count = 4;
   };
}
