{ ... }@inputs:
with inputs;
with flake-utils.lib;
with nixpkgs.lib;
with pkgs;
let
  mkFilter = action: writeShellScript "filter" ''
    export PATH=${makeBinPath [ sops nixFlakes nixfmt coreutils findutils gawk gnupg ]}
    export sopsPGPKeyDirs='${toString sopsPGPKeyDirs}'
    source ${sops-nix.packages.${system}.sops-import-keys-hook}/nix-support/setup-hook
    ${action}
  '';
  sops-git-filter-clean = mkFilter ''
    # <<<sh>>>
    content=$(cat)
    sopsImportKeysHook && \
    (nix eval --json --expr "$content"|sops --input-type=json -e /dev/stdin|nix eval --expr "builtins.fromJSON '''""$(cat)""'''"|nixfmt) \
    || exit 1
    # >>>sh<<<
  '';
  sops-git-filter-smudge = mkFilter ''
    # <<<sh>>>
    content=$(cat)
    encfile=$(mktemp --suffix ".json")
    sopsImportKeysHook && \
    (nix eval --json --expr "$content" > $encfile) && (sops --input-type=json -d $encfile|nix eval --expr "builtins.fromJSON '''""$(cat)""'''"|nixfmt) \
    || (echo $content|nixfmt)
    # >>>sh<<<
  '';
  sops-git-diff = writeShellScript "diff" ''
    export PATH=${makeBinPath [ nixFlakes nixfmt coreutils ]}
    # <<<sh>>>
    nix eval --json --expr "$(cat $1)"|nix eval --expr "builtins.fromJSON '''""$(cat)""'''"|nixfmt
    # >>>sh<<<
  '';
in {
  devShell.${system} = mkShell {
    inherit sopsPGPKeyDirs;
    nativeBuildInputs = [ sops-nix.packages.${system}.sops-import-keys-hook ];
  };

  apps.${system} = let
    fire = os:
      mkApp {
        drv = let toplevel = os.config.system.build.toplevel;
        in writeShellScriptBin "world" ''
          if [[ $1 == "build" ]];then
            echo "Build finished"
          else
            if [[ $1 != "test" ]];then
              sudo ${nixFlakes}/bin/nix-env -p /nix/var/nix/profiles/system --set ${toplevel}
            fi
            exec sudo ${toplevel}/bin/switch-to-configuration "$@"
          fi
        '';
      };
  in {
    world = fire nixosConfigurations.mlatus;
    wsl = fire nixosConfigurations.wsl;
    commit = mkApp {
      drv = writeShellScriptBin "commit" ''
        export EDITOR=$(${coreutils}/bin/realpath $(which $EDITOR))
        export PATH=${makeBinPath [ git nixFlakes coreutils ]}:/bin
        pushd ${entry}

        echo Install hooks

        cat > .git/hooks/pre-commit <<EOF
        #!${runtimeShell}
        touch .commit-unfinished
        EOF
        chmod +x .git/hooks/pre-commit

        cat > .git/hooks/post-commit <<EOF
        #!${runtimeShell}
        if [[ -e .commit-unfinished ]];then
          rm .commit-unfinished
          git log --format=%B -n 1|tr -d ':/\n'|tr -d "'"|tr '[:space:]' '_' > tag.txt
          git add tag.txt
          git commit --amend -C HEAD --no-verify
        fi
        EOF
        chmod +x .git/hooks/post-commit

        echo Setup filter
        git config filter.sops-nix.clean ${sops-git-filter-clean}
        git config filter.sops-nix.smudge ${sops-git-filter-smudge}
        git config filter.sops-nix.required true
        git config diff.sops-nix.textconv ${sops-git-diff}

        echo Commit
        git add .
        git commit

        popd
      '';
    };
    net = mkApp {
      drv = let
        node = nixosConfigurations.cyber.config;
        def = node.system.build.toplevel;
        key = "/var/lib/sops/key";
        dir = "/var/lib/sops";
        host = node.secrets.decrypted.v-host;
      in writeShellScriptBin "net" ''
        export PATH=${makeBinPath [ git openssh coreutils nixFlakes ]}
        # <<<sh>>>
        set -ex
        tmp=$(mktemp -d)
        keyFile=$1
        shift
        key="$tmp/key"

        function cleanup() {
          set +e
          rm -rf "$tmp"
          while true;do
            echo 'Removing keyfile on server...'
            ssh root@${host} 'if [[ -e ${key} ]];then rm ${key};fi' \
            && break || echo 'Failed, try again.'
          done
        }
        trap cleanup EXIT

        cp "$keyFile" "$key"
        echo Decrypt Key File
        ssh-keygen -p -N "" -f "$key"
        ssh root@${host} 'mkdir -p ${dir};if [[ -e ${key} ]];then rm ${key};fi'
        scp "$key" root@${host}:${key}
        rm "$key"
        nix copy -s --to ssh://root@${host} "${def}"
        ssh root@${host} ${def}/bin/switch-to-configuration switch
        # >>>sh<<<
      '';
    };
  };
}
