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
    apply  = import ./apply.nix  { inherit fn pkgs self; };
    cast   = import ./cast.nix   { inherit fn pkgs self; };
    commit = import ./commit.nix { inherit fn lib var pkgs; };
  };

  nixosConfigurations.lego =
    import ./lego.nix { inherit fn lib var self inputs; };

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
    modules = [ ../impl/echo/image.nix ];
  }).config.system.build.image;
}
