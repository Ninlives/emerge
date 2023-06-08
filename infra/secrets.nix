{ pkgs, lib, ... }:
with pkgs;
with lib;
let file = "${../bombe/data/infra/tokens.yaml}";
in {
  options.ref = mkOption { type = types.attrs; };
  config = {
    data.sops_file.secrets.source_file = file;
    locals.secrets = "\${yamldecode(data.sops_file.secrets.raw)}";
    ref.local.secrets = mapAttrsRecursive
      (path: _: "\${local.secrets.${concatStringsSep "." path}}") (importJSON
        (runCommandLocal "secrets" {}
          "${yaml2json}/bin/yaml2json < ${file} > $out"));
  };
}
