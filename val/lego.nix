{
  fn,
  lib,
  self,
  inputs,
  withSystem,
  ...
}:
with lib;
with inputs;
with self.mod; let
  baseModules = [
    home-manager.nixosModule

    bombe
    opt.profile
    opt.revive
    opt.sops

    impl.lego.meta
    impl.lego.baseline
    impl.lego.browser
    impl.lego.gnome-basic
    impl.lego.gnome-local
    impl.lego.gui
    impl.lego.proxy
    impl.lego.security

    impl.lego.jovian
    impl.lego.keychron

    ({config, ...}: {
      system.nixos.tags = mkAfter [(builtins.readFile ../tag.txt)];
      sops.roles = ["net" "phys"];

      home-manager.users.${config.profile.user.name} = {...}: {
        imports = [impl.neko];
      };
    })
  ];
in {
  flake.nixosConfigurations.lego = withSystem "x86_64-linux" ({
    inputs',
    system,
    ...
  }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit fn self inputs inputs';};
      modules =
        baseModules
        ++ [
          impl.lego.dns
          impl.lego.extra-private
          {
            specialisation.institute = {
              inheritParentConfig = false;
              configuration.imports = baseModules ++ [impl.lego.extra-work];
            };
          }
        ];
    });
}
