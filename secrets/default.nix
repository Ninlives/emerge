{ config, pkgs, lib, profile, ... }:
let
  inherit (pkgs) yaml2json runCommandLocal;
  inherit (builtins)
    filter readFile fromJSON concatLists isString listToAttrs attrNames;
  inherit (lib) removePrefix hasInfix;
  inherit (lib.filesystem) listFilesRecursive;
  importYAML = path:
    fromJSON (readFile (runCommandLocal "content.json" { }
      "${yaml2json}/bin/yaml2json < ${path} > $out"));
  keys = profile:
    let
      source = ./data/${profile}/tokens.yaml;
      content = removeAttrs (importYAML source) [ "sops" ];
      generateKeys = attr:
        concatLists (map (k:
          if isString attr.${k} then
            [ k ]
          else
            map (subkey: "${k}/${subkey}") (generateKeys attr.${k}))
          (attrNames attr));
    in listToAttrs (map (k: {
      name = k;
      value = {
        format = "yaml";
        sopsFile = source;
      };
    }) (generateKeys content));
  binaries = profile:
    let files = listFilesRecursive ./data/${profile};
    in listToAttrs (map (f: {
      name = removePrefix ((toString ./data) + "/${profile}/") (toString f);
      value = {
        format = "binary";
        sopsFile = f;
      };
    }) (filter (f: f != ./data/${profile}/tokens.yaml) files));
in {
  secrets.decrypted = import ./encrypt;
  sops.defaultSopsFile = ./data/general/tokens.yaml;
  sops.secrets = keys "general" // keys profile // binaries "general"
    // binaries profile;
}
