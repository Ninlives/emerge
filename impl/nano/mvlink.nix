{
  pkgs,
  args,
  config,
  ...
}:
with pkgs; let
  rm = "${coreutils}/bin/rm";
  basename = "${coreutils}/bin/basename";
  realpath = "${coreutils}/bin/realpath";
  ln = "${coreutils}/bin/ln";
in {
  system.build.mvLink = writeShellScriptBin "mv-link" ''
    set -ex
    src=$1
    dst=$2

    echo "Removing old links..."
    for l in "$dst"/*;do
      if [[ -L "$l" ]];then
        ${rm} "$l"
      fi
    done

    echo "Constructing new links..."
    for l in "$src"/*;do
      if [[ -L "$l" ]];then
        f=$(${basename} "$l")
        o=$(${realpath} "$l")
        ${ln} -s "${args.fs.entry}/$o" "$dst/$f"
      fi
    done
  '';
  environment.systemPackages = [config.system.build.mvLink];
}
