{ fn, lib, var, self, inputs }:
with lib;
with inputs;
fn.mkCube {
  specialArgs = { inherit fn var self inputs; };
  modules = fn.dotNixFromRecursive ../impl/lego ++ [
    ../bombe
    ../opt/smartdns.nix
    ../opt/revive.nix
    ../opt/sops-profiles.nix
    ../opt/workspace.nix
    ../opt/unfree.nix
    home-manager.nixosModule
    sops-nix.nixosModules.sops
    inputs.lanzaboote.nixosModules.lanzaboote

    ({ config, ... }: {
      system.nixos.tags = mkAfter [ (builtins.readFile ../tag.txt) ];

      nixpkgs.overlays = map (o: import o { inherit fn var inputs; })
        (fn.dotNixFromRecursive ../pkg);

      sops.profiles = [ "general" "local" ];

      home-manager.users.${config.workspace.user.name} = { ... }: {
        imports = fn.dotNixFromRecursive ../impl/neko;
      };
    })
  ];
}
