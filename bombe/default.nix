{ config, pkgs, lib, fn, ... }:

with lib;
with pkgs;
with builtins;
with lib.filesystem;

let
  isYAML = f: hasSuffix ".yaml" (toString f);

  keys = profile:
    let
      sources = filter (f: isYAML f) (listFilesRecursive ./data/${profile});
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
    let files = listFilesRecursive ./data/${profile};
    in listToAttrs (map (f: {
      name = removePrefix ((toString ./data) + "/${profile}/") (toString f);
      value = {
        format = "binary";
        sopsFile = f;
      };
    }) (filter (f: !(isYAML f)) files));
in {
  imports = [ ./secrets.nix ];
  sops.defaultSopsFile = ./data/general/tokens.yaml;
  sops.secrets = foldl (a: b: a // b) { }
    (map (profile: keys profile // binaries profile) config.sops.profiles);
}
