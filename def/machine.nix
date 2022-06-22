{ fn, lib, var, self, inputs }:
with lib;
with inputs;
let
  specialArgs = {
    inherit fn var self inputs;
    profile = "local";
  };
  modules = fn.dotNixFromRecursive ../impl/machine ++ [
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
        imports = fn.dotNixFromRecursive ../impl/home;
      };
    }
  ];

  preprocess = nixosSystem {
    inherit (var) system;
    inherit specialArgs modules;
  };
in nixosSystem {
  inherit specialArgs;
  inherit (var) system;
  modules = modules ++ (builtins.attrValues
    preprocess.config.home-manager.users.${var.user.name}.requestNixOSConfig);
}
