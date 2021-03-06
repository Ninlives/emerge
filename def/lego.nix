{ fn, lib, var, self, inputs }:
with lib;
with inputs;
fn.mkCube {
  specialArgs = {
    inherit fn var self inputs;
    profile = "local";
  };
  modules = fn.dotNixFromRecursive ../impl/lego ++ [
    ../bombe
    home-manager.nixosModule
    sops-nix.nixosModules.sops
    external.nixosModules.nixos-cn
    external.nixosModules.nixos-cn-registries

    {
      system.nixos.tags = mkAfter [ (builtins.readFile ../tag.txt) ];

      nixpkgs.overlays = map (o: import o { inherit fn var inputs; })
        (fn.dotNixFromRecursive ../pkg);

      home-manager.users.${var.user.name} = { ... }: {
        imports = fn.dotNixFromRecursive ../impl/neko;
      };
    }
  ];
}
