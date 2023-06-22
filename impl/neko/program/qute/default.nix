{ config, pkgs, lib, var, nixosConfig, inputs, ... }:
with pkgs;
let
  inherit (var) proxy;
  inherit (lib) fold mkIf;
  inherit (builtins) readFile;
  dp = inputs.values.secret;
  scrt = nixosConfig.sops.secrets;

  mergeFiles = files: fold (s1: s2: s1 + s2) "" (map readFile files);
  outPath = placeholder "out";
  vaultwardenScript = resholve.writeScript "vaultwarden-fill" {
    inputs = [ keyutils rofi xclip jq bitwarden-cli-wrapper coreutils gnused ];
    interpreter = "${bash}/bin/bash";
    execer = [
      "cannot:${keyutils}/bin/keyctl"
      "cannot:${bitwarden-cli-wrapper}/bin/bw"
      "cannot:${rofi}/bin/rofi"
    ];
  } (readFile (substituteAll {
    src = ./bitwarden.sh;
  }));
  configPy = mergeFiles [
    (substituteAll {
      src = ./config.py;
      proxy_address = proxy.address;
      local_port = proxy.port.local;
      acl_port = proxy.port.acl;
      keyctl = "${keyutils}/bin/keyctl";
    })
    ./gruvbox.py
  ];
  enabled = config.programs.qutebrowser.enable;
in mkIf config.programs.qutebrowser.enable {
  programs.qutebrowser = {
    package = symlinkJoin {
      name = "qutebrowser";
      paths = [ qutebrowser ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram ${outPath}/bin/qutebrowser \
        --add-flags "--qt-flag ignore-gpu-blacklist" \
        --add-flags "--qt-flag enable-gpu-rasterization" \
        --add-flags "--qt-flag enable-native-gpu-memory-buffers" \
        --add-flags "--qt-flag enable-accelerated-video-decode"
      '';
    };

    loadAutoconfig = true;
    settings = {
      auto_save.session = true;
      editor.command = [
        "${config.lib.packages.gnvim}/bin/gnvim"
        "--"
        "{file}"
        "-c"
        "normal {line}G{column0}l"
      ];
      content.javascript.can_access_clipboard = true;
      content.pdfjs = true;
      content.proxy = "socks://${proxy.address}:${toString proxy.port.acl}";
      logging.level.console = "info";
      logging.level.ram = "info";
      qt.highdpi = true;
      scrolling.smooth = true;
    };

    keyBindings = {
      normal = {
        J = "tab-prev";
        K = "tab-next";
      };
      insert = { "<Ctrl-p>" = "spawn --userscript ${vaultwardenScript}"; };
    };

    extraConfig = configPy;
  };

  persistent.boxes = lib.mkIf enabled [
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
