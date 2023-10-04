{
  fn,
  self,
  withSystem,
  inputs,
  ...
}:
with inputs;
with self.mod; {
  flake.pathogen.ipomoea = username: homeDirectory:
    withSystem "x86_64-linux" ({
      system,
      pkgs,
      ...
    }: let
      ttyOnly = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [];
      };
    in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit fn self inputs;
          nixosConfig = ttyOnly.config;
        };
        modules = [
          impl.neko
          {home = {inherit username homeDirectory;};}
        ];
      });

  flake.pathogen.physeter = { fs, ... }@args: withSystem "x86_64-linux" ({
    inputs',
    system,
    ...
  }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit fn args self inputs inputs';};
      modules = [
        impl.nano
      ];
    });
}
