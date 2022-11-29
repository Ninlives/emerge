{ fn, lib, var, pkgs, self, inputs }:
with fn;
with lib;
with var;
with pkgs;
with inputs; {
  devShell.${system} = mkShell {
    nativeBuildInputs = [ terrasops.packages.${system}.default terraform sops age jq curl ];
  };

  apps.${system} = {
    apply  = import ./apply.nix  { inherit fn pkgs self; };
    commit = import ./commit.nix { inherit fn lib var pkgs; };
  };

  nixosConfigurations = {
    lego = import ./lego.nix { inherit fn lib var self inputs; };
    inherit (import ./cyber.nix { inherit fn lib var self inputs; })
    echo coco;
  };

  legacyPackages.${system} = import nixpkgs {
    inherit system;
    overlays = map (o: import o { inherit fn var inputs; })
      (fn.dotNixFromRecursive ../pkg);
    config.allowUnfree = true;
  };
}
