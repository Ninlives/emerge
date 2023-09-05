{
  fn,
  self,
  inputs,
  moduleWithSystem,
  ...
}:
with inputs;
with self.mod; {
  flake.nixosConfigurations.echo = nixpkgs.lib.nixosSystem {
    specialArgs = {inherit fn self inputs;};
    modules = [
      sops-nix.nixosModules.sops

      bombe
      opt.revive
      opt.rathole
      opt.sops

      impl.echo
      {
        sops.roles = ["net" "connect" "server"];
        nixpkgs.overlays = self.overlays';
      }
    ];
  };

  flake.terraformConfigurations.zero = moduleWithSystem ({
    pkgs,
    system,
  }:
    (terranix.lib.terranixConfiguration {
      inherit pkgs;
      inherit system;
      extraArgs = {
        inherit inputs;
        inherit (self.nixosConfigurations) echo;
      };
      modules = fn.dotNixFromRecursive ../infra;
    })
    .overrideAttrs (_: {allowSubstitutes = false;}));
}
