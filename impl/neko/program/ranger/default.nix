{
  pkgs,
  lib,
  ...
}:
with pkgs; let
  deviconPlugin = stdenv.mkDerivation {
    name = "ranger-devicons2";
    src = fetchFromGitHub {
      owner = "cdump";
      repo = "ranger-devicons2";
      rev = "f7877aa0dd8caa1d498d935f6f49e57a4fc591e2";
      sha256 = "sha256-OMMQW/mn8J8mki41TD/7/CWaDFgp/zT7B2hfTH/m0Ug=";
    };
    buildInputs = [python3];

    buildPhase = ''
      python3 -m compileall .
    '';

    installPhase = ''
      cp -r . $out
    '';
  };

  compressCommand = runCommand "compress.py" {inherit atool;} ''
    substituteAll ${./compress.py} ${placeholder "out"}
  '';
in {
  home.packages = [ranger bat];

  xdg.configFile = {
    ranger = {
      source = runCommand "config" {} ''
        cp --no-preserve=all -r ${ranger}/share/doc/ranger/config $out

        sed -i 's/set colorscheme default/set colorscheme ls_colors/' $out/rc.conf

        sed -i '/handle_fallback$/i if [[ $(realpath "''${FILE_PATH}") = /proc* && ! -L "''${FILE_PATH}" ]];then \
          exit 2 \
        fi' $out/scope.sh
        chmod +x $out/scope.sh

        sed -i 's#set preview_script .*#set preview_script '$out/scope.sh'#' $out/rc.conf
        sed -i 's#set preview_images_method .*#set preview_images_method kitty#' $out/rc.conf
        echo "default_linemode devicons2" >> $out/rc.conf

        cat ${compressCommand} >> $out/commands.py

        sed -i -e '/# Documents/!{p;d;};N;a ext org = ''${VISUAL:-$EDITOR} -- "$@"' $out/rifle.conf
      '';
      recursive = true;
    };

    "ranger/plugins/devicons2" = {
      source = "${deviconPlugin}";
      recursive = true;
    };

    "ranger/colorschemes/ls_colors.py".source = ./ls_colors.py;
  };

  home.sessionVariables = {
    BAT_THEME = "gruvbox-dark";
    RANGER_DEVICONS_SEPARATOR = "  ";
  };

  persistent.boxes = [
    {
      src = /Programs/ranger;
      dst = ".local/share/ranger";
    }
  ];
}
