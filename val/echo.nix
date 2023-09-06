{
  fn,
  self,
  inputs,
  withSystem,
  ...
}:
with inputs;
with self.mod; {
  flake.nixosConfigurations.echo = withSystem "x86_64-linux" ({system, ...}:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit fn self inputs;};
      modules = [
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
    });

  flake.terraformConfigurations.zero = withSystem "x86_64-linux" ({
    pkgs,
    system,
    ...
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
