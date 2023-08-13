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
    cast   = import ./cast.nix { inherit fn var self pkgs inputs; };
    apply  = import ./apply.nix  { inherit fn pkgs self; };
    infect = import ./infect.nix { inherit fn pkgs self; };
    commit = import ./commit.nix { inherit fn lib var pkgs; };
  };

  nixosConfigurations = {
    lego = import ./lego.nix { inherit fn lib var self inputs; };
    inherit (import ./cyber.nix { inherit fn lib var self inputs; })
    echo coco;
  };

  homeInfections.nemo = username: homeDirectory: let 
    ttyOnly = lib.nixosSystem {
      inherit (var) system;
      modules = [];
    };
  in inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = { inherit fn var self inputs; nixosConfig = ttyOnly.config; };
    modules = (fn.dotNixFromRecursive ../impl/neko/option)
      ++ (fn.dotNixFromRecursive ../impl/neko/misc) ++ [
      ../impl/neko/program/zsh
      ../impl/neko/program/neovim
      ../impl/neko/program/ranger
      ../impl/neko/program/dircolors
      { home = { inherit username homeDirectory; }; }
    ];
  };

  terraformConfigurations.zero = (inputs.terranix.lib.terranixConfiguration {
    inherit pkgs;
    inherit (var) system;
    extraArgs = {
      inherit var inputs;
      inherit (self.nixosConfigurations) echo;
    };
    modules = fn.dotNixFromRecursive ../infra;
  }).overrideAttrs(_: { allowSubstitutes = false; });

  legacyPackages.${system} = import nixpkgs {
    inherit system;
    overlays = map (o: import o { inherit fn var inputs; })
      (fn.dotNixFromRecursive ../pkg);
  };
}
