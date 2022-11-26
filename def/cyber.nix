{ fn, lib, var, self, inputs }:
with lib;
with inputs;
fix (self: {
  echo = fn.mkCube {
    specialArgs = {
      inherit fn var self inputs;
      profile = "server";
    };
    modules = [
      ../impl/echo
      ../bombe
      ../opt/revive.nix
      ../opt/rathole.nix
      sops-nix.nixosModules.sops
      external.nixosModules.nixos-cn
      {
        nixpkgs.overlays = map (o: import o { inherit fn var inputs; })
          (fn.dotNixFromRecursive ../pkg);
      }
    ];
  };
  nano = fn.mkCube {
    specialArgs = {
      inherit fn var self inputs;
      profile = "server";
    };
    modules = [ ../impl/nano ];
  };

  coco = fn.mkCube {
    specialArgs = {
      inherit fn var self inputs;
      profile = "home";
    };
    modules = [
      ../impl/coco
      ../bombe
      ../opt/revive.nix
      ../opt/rathole.nix
      sops-nix.nixosModules.sops
      external.nixosModules.nixos-cn
    ];
  };
})
