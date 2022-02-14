{ config, pkgs, lib, profile, ... }:
let
  inherit (pkgs) yaml2json runCommandLocal;
  inherit (builtins)
    filter readFile fromJSON concatLists isString listToAttrs attrNames;
  inherit (lib) removePrefix hasInfix;
  inherit (lib.filesystem) listFilesRecursive;
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
  in listToAttrs (map (k: {
    name = k;
    value = { };
  }) (generateKeys content));
  binaries = let
    files = listFilesRecursive ./data;
    filterFunc = f:
      !(hasInfix (if profile == "local" then "/server/" else "/local/")
        (toString f));
  in listToAttrs (map (f: {
    name = removePrefix ((toString ./data) + "/") (toString f);
    value = {
      format = "binary";
      sopsFile = f;
    };
  }) (filter filterFunc files));
in {
  secrets.decrypted = import ./encrypt;
  sops.defaultSopsFile = sopsFile;
  sops.secrets = keys // binaries;
}
