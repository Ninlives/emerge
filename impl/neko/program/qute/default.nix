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
      sVAULTWARDEN_SCRIPT = vaultwardenScript;
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
        --add-flags "--qt-flag ignore-gpu-blacklist" \
        --add-flags "--qt-flag enable-gpu-rasterization" \
        --add-flags "--qt-flag enable-native-gpu-memory-buffers" \
        --add-flags "--qt-flag enable-accelerated-video-decode"
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

  requestNixOSConfig.qute.sops.secrets."vaultwarden/client-id".owner = var.user.name;
  requestNixOSConfig.qute.sops.secrets."vaultwarden/client-secret".owner = var.user.name;
}
