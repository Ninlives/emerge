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
    home-manager.nixosModules.home-manager
    disko.nixosModules.disko

    bombe
    opt.profile
    opt.revive
    opt.sops

    impl.lego.m-meta
    impl.lego.m-baseline
    impl.lego.m-browser
    impl.lego.m-gnome-basic
    impl.lego.m-gnome-local
    impl.lego.m-gui
    impl.lego.m-proxy
    impl.lego.m-security

    impl.lego.m-hardware
    impl.lego.m-keychron

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
          # impl.lego.dns
          impl.lego.m-extra
          impl.lego.d-jovian-hardware
          impl.lego.d-jovian-extra-private
          {
            specialisation.institute = {
              inheritParentConfig = false;
              configuration.imports = baseModules ++ [impl.lego.hardware-jovian impl.lego.extra-work];
            };
          }
        ];
    });

  flake.nixosConfigurations.holo = withSystem "x86_64-linux" ({
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
          impl.lego.m-extra
          impl.lego.d-desktop-hardware
          impl.lego.d-desktop-extra
        ];
    });

  flake.fabrica = withSystem "x86_64-linux" ({
    inputs',
    system,
    ...
  }:
    (nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ({modulesPath, pkgs, ...}: {
          imports = [(modulesPath + "/installer/cd-dvd/installation-cd-graphical-gnome.nix")];
          environment.systemPackages = with self.nixosConfigurations.holo.config.system.build; [
            destroy format mount unmount
            (pkgs.writeShellScriptBin "fabrica-install" ''
              exec ${nixos-install}/bin/nixos-install --system ${toplevel} "$@"
            '')
          ];
        })];
    }).config.system.build.isoImage);
}
