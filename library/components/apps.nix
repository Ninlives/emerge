{ ... }@inputs:
with inputs;
with flake-utils.lib;
with nixpkgs.lib;
with pkgs;
{
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
        export PATH=${makeBinPath [ git nix coreutils sops bash ]}
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
          git log --format=%B -n 1|tr -d ':/\n'|tr -d "'"|tr '[:space:]' '_'|tr ';' '-' > tag.txt
          git add tag.txt
          git commit --amend -C HEAD --no-verify
        fi
        EOF
        chmod +x .git/hooks/post-commit

        echo Setup filter
        git config filter.sops-nix.clean sops-git-filter-clean
        git config filter.sops-nix.smudge sops-git-filter-smudge
        git config filter.sops-nix.required true
        git config diff.sops-nix.textconv sops-git-diff

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
        host = node.secrets.decrypted.v2ray.host;
      in writeShellScriptBin "net" ''
        export PATH=${makeBinPath [ git openssh coreutils nixFlakes keyutils ]}
        # <<<sh>>>
        set -e
        tmp=$(mktemp -d)
        chmod 700 "$tmp"
        reboot=0
        if [[ "$1" == "-r" ]];then
          reboot=1
          shift
        fi
        keyFile=$1
        shift
        key="$tmp/key"

        function cleanup() {
          set +e
          rm -rf "$tmp"
          while true;do
            echo 'Removing keyfile on server...'
            ssh root@${host} 'if [[ -e ${key} ]];then rm ${key};fi' \
            && break || (echo 'Failed, try again.'; sleep 1)
          done
        }
        trap cleanup EXIT

        function getpass(){
          if ! key_id=$(keyctl request user emerge:ssh_keypass @s 2> /dev/null);then
            echo -n 'Input passphrase: ' >&2
            read -s ssh_keypass
            echo "$ssh_keypass"|keyctl padd user emerge:ssh_keypass @s > /dev/null
            echo "$ssh_keypass"
          else
            echo $(keyctl pipe "$key_id")
          fi
        }

        clearpass(){
          if key_id=$(keyctl request user emerge:ssh_keypass @s 2> /dev/null);then
            keyctl revoke "$key_id"
          fi
        }

        cp "$keyFile" "$key"
        echo Decrypt Key File
        ssh-keygen -p -P "$(getpass)" -N "" -f "$key" || { clearpass; exit 1; }
        ssh root@${host} 'mkdir -p ${dir};if [[ -e ${key} ]];then rm ${key};fi'
        scp "$key" root@${host}:${key}
        rm "$key"
        nix copy -s --to ssh://root@${host} "${def}"

        if [[ $reboot -eq 1 ]];then
          ssh root@${host} ${def}/bin/switch-to-configuration boot
          ssh root@${host} reboot
        else
          ssh root@${host} ${def}/bin/switch-to-configuration switch
        fi
        # >>>sh<<<
      '';
    };
  };
}
