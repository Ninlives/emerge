{ ... }@inputs:
with inputs;
with nixpkgs.lib; {
  mkNixOS = profile: extraConfig:
    let
      specialArgs' = inputs.specialArgs // { inherit profile; };
      modules = [
        external.nixosModules.nixos-cn-registries
        external.nixosModules.nixos-cn
        home-manager.nixosModule

        ({ ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs';
        })

        ({ ... }: {
          system.nixos.tags = mkAfter [ (builtins.readFile ../../tag.txt) ];
          nixpkgs.overlays = mergedOverlays;
          nixpkgs.config = nixpkgsConfig;

          nix.registry.emerge.to = {
            type = "git";
            url = "file://${toString entry}";
          };
          revive.specifications.with-snapshot-home.boxes = [ entry secrets ];
        })

        ({ pkgs, ... }: {
          environment.systemPackages = [
            (pkgs.writeShellScriptBin "emerge" ''
              app=$1
              shift
              nix run emerge#$app -- $@
            '')
          ];
        })
      ] ++ extraConfig;
      preprocess = nixpkgs.lib.nixosSystem {
        inherit system modules;
        specialArgs = specialArgs';
      };
    in nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = specialArgs';
      modules = modules ++ (builtins.attrValues
        preprocess.config.home-manager.users.${constant.user.name}.nixosConfig);
    };
}
