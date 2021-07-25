{ ... }@inputs:
with inputs;
with nixpkgs.lib; {
  mkNixOS = extraConfig:
    let
      modules = [
        external.nixosModules.nixos-cn-registries
        external.nixosModules.nixos-cn
        home-manager.nixosModules.home-manager

        ({ ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;
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
            (pkgs.writeTextDir "share/zsh/site-functions/_nix" ''
              # <<<sh>>>
              function _nix() {
                local ifs_bk="$IFS"
                local input=("''${(Q)words[@]}")
                IFS=$'\n'
                local res=($(NIX_GET_COMPLETIONS=$((CURRENT - 1)) "$input[@]"))
                IFS="$ifs_bk"
                local tpe="''${''${res[1]}%%>	*}"
                local -a suggestions
                declare -a suggestions
                for suggestion in ''${res:1}; do
                  # FIXME: This doesn't work properly if the suggestion word contains a `:`
                  # itself
                  suggestions+="''${suggestion/	/:}"
                done
                if [[ "$tpe" == filenames ]]; then
                  compadd -f
                fi
                _describe 'nix' suggestions
              }

              _nix "$@"
              # >>>sh<<<
            '')
            (pkgs.writeShellScriptBin "emerge" ''
              app=$1
              shift
              nix run emerge#$app -- $@
            '')
          ];
        })
      ] ++ extraConfig;
      preprocess =
        nixpkgs.lib.nixosSystem { inherit system specialArgs modules; };
    in nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = modules ++ (builtins.attrValues
        preprocess.config.home-manager.users.${constant.user.name}.nixosConfig);
    };
}
