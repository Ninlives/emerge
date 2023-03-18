{ fn, lib, var, self, inputs }:
with lib;
with inputs;
fix (self: {
  echo = fn.mkCube {
    specialArgs = { inherit fn var self inputs; };
    modules = [
      ../impl/echo
      ../bombe
      ../opt/revive.nix
      ../opt/rathole.nix
      ../opt/sops-profiles.nix
      sops-nix.nixosModules.sops
      {
        sops.profiles = [ "general" "server" ];
        nixpkgs.overlays = map (o: import o { inherit fn var inputs; })
          (fn.dotNixFromRecursive ../pkg);
      }
    ];
  };

  coco = fn.mkCube {
    specialArgs = { inherit fn var self inputs; };
    modules = [
      ../impl/coco
      ../bombe
      ../opt/revive.nix
      ../opt/rathole.nix
      ../opt/sops-profiles.nix
      sops-nix.nixosModules.sops
      { sops.profiles = [ "general" "home" ]; }
    ];
  };
})
