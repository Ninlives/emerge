{ pkgs, config, lib, ... }:
with pkgs;
let
  inherit (lib) optionalString;

  deviconPlugin = stdenv.mkDerivation {
    name = "ranger-devicon";
    src = fetchFromGitHub {
      owner = "alexanderjeurissen";
      repo = "ranger_devicons";
      rev = "49fe4753c89615a32f14b2f4c78bbd02ee76be3c";
      sha256 = "1kgzv9mqsqzbpjrj3qi8vkha7vij2qsmdnjwl547pnf04hbdhgk1";
    };
    buildInputs = [ python3 ];

    buildPhase = ''
      python3 -m compileall .
    '';

    installPhase = ''
      cp -r . $out
    '';
  };

  compressCommand = runCommand "compress.py" { inherit atool; } ''
    substituteAll ${./compress.py} ${placeholder "out"}
  '';

in {
  home.packages = [ ranger bat ];

  xdg.configFile = {
    ranger = {
      source = runCommand "config" { } ''
        cp --no-preserve=all -r ${ranger}/share/doc/ranger/config $out

        sed -i 's/set colorscheme default/set colorscheme ls_colors/' $out/rc.conf

        sed -i '/handle_fallback$/i if [[ $(realpath "''${FILE_PATH}") = /proc* && ! -L "''${FILE_PATH}" ]];then \
          exit 2 \
        fi' $out/scope.sh
        chmod +x $out/scope.sh

        sed -i 's#set preview_script .*#set preview_script '$out/scope.sh'#' $out/rc.conf
        sed -i 's#set preview_images_method .*#set preview_images_method kitty#' $out/rc.conf
        echo "default_linemode devicons" >> $out/rc.conf

        cat ${compressCommand} >> $out/commands.py
      '';
      recursive = true;
    };

    "ranger/plugins/ranger_devicons" = {
      source = "${deviconPlugin}";
      recursive = true;
    };

    "ranger/colorschemes/ls_colors.py".source = ./ls_colors.py;
  };

  home.sessionVariables = { BAT_THEME = "gruvbox-dark"; RANGER_DEVICONS_SEPARATOR = "  "; };

  persistent.boxes = [{
    src = /Programs/ranger;
    dst = ".local/share/ranger";
  }];
}
