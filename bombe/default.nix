{ config, pkgs, lib, fn, ... }:

with lib;
with pkgs;
with builtins;
with lib.filesystem;

let
  isYAML = f: hasSuffix ".yaml" (toString f);
  listFilesIfExists = path: if pathExists path then
                              listFilesRecursive path
                            else [];

  keys = profile:
    let
      sources = filter (f: isYAML f) (listFilesIfExists ./data/${profile});
      contents = map (f: {
        file = f;
        content = removeAttrs (fn.importYAML f) [ "sops" ];
      }) sources;
      generateKeys = attr:
        concatLists (map (k:
          if isString attr.${k} then
            [ k ]
          else
            map (subkey: "${k}/${subkey}") (generateKeys attr.${k}))
          (attrNames attr));
      keyFiles = { file, content }:
        map (key: { inherit key file; }) (generateKeys content);
    in listToAttrs (map ({ key, file }: {
      name = key;
      value = {
        format = "yaml";
        sopsFile = file;
      };
    }) (concatLists (map keyFiles contents)));

  binaries = profile:
    let files = listFilesIfExists ./data/${profile};
    in listToAttrs (map (f: {
      name = removePrefix ((toString ./data) + "/${profile}/") (toString f);
      value = {
        format = "binary";
        sopsFile = f;
      };
    }) (filter (f: !(isYAML f)) files));
in {
  sops.defaultSopsFile = ./data/net/tokens.yaml;
  sops.secrets = foldl (a: b: a // b) { }
    (map (profile: keys profile // binaries profile) config.sops.profiles);
}
