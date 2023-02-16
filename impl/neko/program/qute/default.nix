{ config, pkgs, lib, var, nixosConfig, ... }:
with pkgs;
let
  inherit (var) proxy;
  inherit (lib) fold optionalAttrs mkMerge mkIf;
  inherit (builtins) readFile;
  dp = nixosConfig.secrets.decrypted;
  scrt = nixosConfig.sops.secrets;

  mergeFiles = files: fold (s1: s2: s1 + s2) "" (map readFile files);
  outPath = placeholder "out";
  vaultwardenScript = resholve.writeScript "vaultwarden-fill" {
    inputs = [ keyutils rofi xclip jq bitwarden-cli coreutils gnused ];
    interpreter = "${bash}/bin/bash";
    execer = [
      "cannot:${keyutils}/bin/keyctl"
      "cannot:${bitwarden-cli}/bin/bw"
      "cannot:${rofi}/bin/rofi"
    ];
  } (readFile (substituteAll {
    src = ./bitwarden.sh;
    sVAULTWARDEN_HOST = "${dp.vaultwarden.subdomain}.${dp.host}";
    sVAULTWARDEN_CLIENTID = scrt."vaultwarden/client-id".path;
    sVAULTWARDEN_CLIENTSECRET = scrt."vaultwarden/client-secret".path;
  }));
  configPy = mergeFiles [
    (substituteAll {
      src = ./config.py;

      sPROXY_ADDRESS = proxy.address;
      sLOCAL_PORT = proxy.port.local;
      sACL_PORT = proxy.port.acl;
      sKEYCTL = "${keyutils}/bin/keyctl";
    })
    ./gruvbox.py
  ];
  enabled = config.programs.qutebrowser.enable;
in {
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
      content.javascript.can_access_clipboard = true;
      content.proxy = "socks://${proxy.address}:${toString proxy.port.acl}";
      scrolling.smooth = true;
      auto_save.session = true;
      content.pdfjs = true;
      qt.highdpi = true;
      logging.level.console = "info";
      logging.level.ram = "info";
    };

    keyBindings = {
      normal = {
        J = "tab-prev";
        K = "tab-next";
      };
      insert = {
        "<Ctrl-p>" = "spawn --userscript ${vaultwardenScript}";
      };
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

  requestNixOSConfig.qute.sops.secrets."vaultwarden/client-id".owner =
    nixosConfig.workspace.user.name;
  requestNixOSConfig.qute.sops.secrets."vaultwarden/client-secret".owner =
    nixosConfig.workspace.user.name;
}
