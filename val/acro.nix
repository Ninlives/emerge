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
with self.mod; {
  flake.acro = withSystem "aarch64-linux" (
    {
      inputs',
      system,
      ...
    }: let
      jar = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit fn self inputs inputs';};
        modules = [
          home-manager.nixosModule

          bombe
          opt.profile
          # opt.revive
          opt.sops

          impl.lego.meta
          impl.acro

          ({config, ...}: {
            sops.roles = ["net" "phys"];
            home-manager.users.${config.profile.user.name} = {...}: {
              imports = [impl.neko];
            };
          })
        ];
      };
    in
      inputs'.parasyteOS.packages.phantom jar
  );
}
