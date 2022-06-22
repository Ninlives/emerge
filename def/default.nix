{ fn, lib, var, pkgs, self, inputs }:
with fn;
with lib;
with var;
with pkgs;
with inputs; {
  devShell.${system} = mkShell {
    sopsPGPKeyDirs = var.sops.keys;
    nativeBuildInputs = [ sops-nix.packages.${system}.sops-import-keys-hook ];
  };

  apps.${system} = {
    apply = import ./apply.nix { inherit fn pkgs self; };
    commit = import ./commit.nix { inherit fn lib var pkgs; };
    upload = import ./upload.nix { inherit fn pkgs self; };
  };

  nixosConfigurations.machine =
    import ./machine.nix { inherit fn lib var self inputs; };

  legacyPackages.${system} = import nixpkgs {
    inherit system;
    overlays = map (o: import o { inherit fn var inputs; })
      (fn.dotNixFromRecursive ../pkg);
    config.allowUnfree = true;
  };

  packages.${system}.image = (nixosSystem {
    inherit system;
    specialArgs = {
      inherit fn var self inputs;
      profile = "server";
    };
    modules = [ ../bombe ../impl/cyber/image.nix sops-nix.nixosModules.sops ];
  }).config.system.build.image;
}
