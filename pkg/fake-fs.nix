{ ... }:
final: prev: {
  fakeFS = { drv
    , fakeHome ? "$HOME/.local/fakefs/${(builtins.parseDrvName drv.name).name}"
    , extraBinds ? { }
    , exclude ? [ "$HOME/.config" "$HOME/.local" "$HOME/.cache" "$HOME/.ssh" "$HOME/.gnupg" "$HOME/Secrets" ] }:
    with final;
    with final.lib;
    let
      binds = {
        "$HOME/.cache/ibus" = "$HOME/.cache/ibus";
        "$HOME/.config/ibus" = "$HOME/.config/ibus";
      } // extraBinds;
      lndir = "${xorg.lndir}/bin/lndir";
      pwd = "${coreutils}/bin/pwd";
      realpath = "${coreutils}/bin/realpath";
      bwrap = "${bubblewrap}/bin/bwrap";
      fd = "${final.fd}/bin/fd";
    in runCommand "${drv.name}-fake-fs" {
      inherit (drv) passthru;
      preferLocalBuild = true;
      allowSubstitutes = false;
    } ''
      mkdir -p $out
      ${lndir} -silent ${drv} $out

      if [[ -h $out/bin ]];then
        rm $out/bin
        mkdir -p $out/bin
      else
        rm $out/bin/*
      fi
      cd ${drv}/bin

      for i in *;do
      cat > $out/bin/$i <<'EOF'
      #!${stdenv.shell}
      mkdir -p "${fakeHome}"
      for dof in $(${findutils}/bin/find "${fakeHome}" -mindepth 1 -maxdepth 1);do
        if [[ -d "$dof" ]];then
          if [[ -z "$(ls -A "$dof")" ]];then
            rmdir "$dof"
          fi
        else
          if [[ ! -s "$dof" ]];then
            rm "$dof"
          fi
        fi
      done
      blacklist=(/dev /proc /home)
      cmd=(
        ${bwrap}
        --chdir "$(${pwd})"
        --dev-bind /dev /dev
        --proc /proc
        --die-with-parent
      )

      for dir in /*;do
        if [[ ! "''${blacklist[@]}" =~ "$dir" ]]; then
          cmd+=(--bind "$dir" "$dir")
        fi
      done

      cmd+=(--bind "${fakeHome}" $HOME)

      for dir in $(${findutils}/bin/find $HOME -maxdepth 1);do
        if [[ ! "${concatStringsSep " " exclude}" =~ "$dir" ]];then
          cmd+=(--bind "$dir" "$dir")
        else
          cmd+=(--dir "$dir")
        fi
      done

      ${concatStringsSep "\n"
      (mapAttrsToList (src: dest: ''cmd+=(--bind "${src}" "${dest}")'') binds)}

      cmd+=(--)
      EOF

      echo "cmd+=(${drv}/bin/$i)" >> $out/bin/$i
      echo 'exec "''${cmd[@]}" "$@"' >> $out/bin/$i
      chmod +x $out/bin/$i
      done

      if [[ -d "${drv}/share/applications" ]];then
        if [[ -h $out/share/applications ]];then
          rm $out/share/applications
          mkdir -p $out/share/applications
        else
          rm $out/share/applications/*
        fi
        cp ${drv}/share/applications/* $out/share/applications
        for i in $out/share/applications/*;do
          substituteInPlace $i \
            --replace "${drv}" "$out"
        done
      fi
    '';
}
