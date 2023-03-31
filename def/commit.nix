{ fn, lib, var, pkgs }:
with lib;
with pkgs;
fn.mkApp {
  drv = writeShellScriptBin "commit" (''
    export EDITOR=$(${coreutils}/bin/realpath $(which $EDITOR))
    export PATH=${makeBinPath [ git nix coreutils bash ]}
    pushd $HOME/Emerge

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
    '' + /* bash */ ''
    chmod +x .git/hooks/post-commit

    echo Commit
    git add .
    git commit

    popd
  '');
}
