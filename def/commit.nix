{ fn, lib, var, pkgs }:
with lib;
with pkgs;
fn.mkApp {
  drv = writeShellScriptBin "commit" ''
    export EDITOR=$(${coreutils}/bin/realpath $(which $EDITOR))
    export PATH=${makeBinPath [ git nix coreutils sops bash ]}
    pushd ${var.path.entry}

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
}
