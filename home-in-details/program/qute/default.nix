{ config, pkgs, lib, constant, nixosConfig, ... }:
let
  inherit (pkgs)
    qutebrowser substituteAll symlinkJoin makeWrapper keyutils writeShellScript
    resholve xclip jq bitwarden-cli rofi bash coreutils gnused;
  inherit (constant) proxy;
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
    sVAULTWARDEN_HOST = dp.vaultwarden.host;
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

  nixosConfig.qute.sops.secrets."vaultwarden/client-id".owner = constant.user.name;
  nixosConfig.qute.sops.secrets."vaultwarden/client-secret".owner = constant.user.name;
}
