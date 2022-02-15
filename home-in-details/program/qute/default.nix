{ config, pkgs, lib, constant, ... }:
let
  inherit (pkgs) qutebrowser substituteAll symlinkJoin makeWrapper;
  inherit (constant) proxy;
  inherit (lib) fold optionalAttrs mkMerge mkIf;
  inherit (builtins) readFile;
  mergeFiles = files: fold (s1: s2: s1 + s2) "" (map readFile files);
  outPath = placeholder "out";
  configPy = mergeFiles [
    (substituteAll {
      src = ./config.py;
      inherit (proxy) address;
      localPort = proxy.port.local;
      aclPort = proxy.port.acl;
    })
    ./gruvbox.py
  ];
in {
  xdg.configFile."qutebrowser/config.py".text = configPy;
  home.packages = [
    (symlinkJoin {
      name = "qutebrowser";
      paths = [ qutebrowser ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram ${outPath}/bin/qutebrowser \
          --add-flags "--qt-flag ignore-gpu-blacklist --qt-flag enable-gpu-rasterization --qt-flag enable-native-gpu-memory-buffers"
      '';
    })
  ];

  persistent.boxes = [
    {
      src = /Programs/qute/data;
      dst = ".local/share/qutebrowser";
    }
    {
      src = /Programs/qute/config;
      dst = ".config/qutebrowser";
    }
  ];
}
