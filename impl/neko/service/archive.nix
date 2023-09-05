{
  pkgs,
  config,
  nixosConfig,
  ...
}: let
  inherit (pkgs) writeShellScript findutils coreutils;
in {
  systemd.user.services.archive-downloads = {
    Unit = {
      Description = "Archive Downloads files";
    };

    Install = {WantedBy = ["default.target"];};

    Service = {
      ExecStart = "${writeShellScript "archive" ''
        # <<<sh>>>
        HOME=$1
        PATH=${findutils}/bin:${coreutils}/bin
        find $HOME/Downloads -maxdepth 1 -type f -print0 | while IFS= read -r -d "" f;do
            date="$(stat --printf=%y "$f"|cut -f1 -d' ')"
            dest="$HOME/Downloads/Archive/$date"
            mkdir -p "$dest"
            base="$(basename "$f")"
            name="''${base%.*}"
            ext="''${base##*.}"
            while [[ -f "''${dest}/''${name}.''${ext}" ]];do
              name="''${name}_"
            done
            mv "$f" "''${dest}/''${name}.''${ext}"
        done
        # >>>sh<<<
      ''} %h";
      Type = "oneshot";
    };
  };
}
