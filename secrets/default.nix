{ config, pkgs, ... }:
let
  inherit (pkgs) yaml2json runCommandLocal;
  inherit (builtins)
    readFile fromJSON concatLists isString listToAttrs attrNames;
  sopsFile = ./tokens.yaml;
  importYAML = path:
    fromJSON (readFile (runCommandLocal "content.json" { }
      "${yaml2json}/bin/yaml2json < ${path} > $out"));
  keys = let
    content = removeAttrs (importYAML sopsFile) [ "sops" ];
    generateKeys = attr:
      concatLists (map (k:
        if isString attr.${k} then
          [ k ]
        else
          map (subkey: "${k}/${subkey}") (generateKeys attr.${k}))
        (attrNames attr));
  in generateKeys content;
in {
  imports = [ ./token.nix ];
  sops.defaultSopsFile = sopsFile;
  sops.secrets = listToAttrs (map (k: {
    name = k;
    value = { };
  }) keys);
}
