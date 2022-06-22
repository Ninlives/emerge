{ var, inputs, ... }:
final: prev:
with final;
with inputs;
with final.lib;
let
  mkFilter = name: action:
    writeShellScriptBin name ''
      export PATH=${
        makeBinPath [ sops nixFlakes nixfmt coreutils findutils gawk gnupg ]
      }
      export sopsPGPKeyDirs='${toString var.sops.keys}'
      source ${
        sops-nix.packages.${system}.sops-import-keys-hook
      }/nix-support/setup-hook
      ${action}
    '';
in {
  sops-git-filter-clean = mkFilter "sops-git-filter-clean" ''
    # <<<sh>>>
    content=$(cat)
    sopsImportKeysHook && \
    (nix eval --json --expr "$content"|sops --input-type=json -e /dev/stdin|nix eval --expr "builtins.fromJSON '''""$(cat)""'''"|nixfmt) \
    || exit 1
    # >>>sh<<<
  '';
  sops-git-filter-smudge = mkFilter "sops-git-filter-smudge" ''
    # <<<sh>>>
    content=$(cat)
    encfile=$(mktemp --suffix ".json")
    sopsImportKeysHook && \
    (nix eval --json --expr "$content" > $encfile) && (sops --input-type=json -d $encfile|nix eval --expr "builtins.fromJSON '''""$(cat)""'''"|nixfmt) \
    || (echo $content|nixfmt)
    # >>>sh<<<
  '';
  sops-git-diff = writeShellScriptBin "sops-git-diff" ''
    export PATH=${makeBinPath [ nixFlakes nixfmt coreutils ]}
    # <<<sh>>>
    nix eval --json --expr "$(cat $1)"|nix eval --expr "builtins.fromJSON '''""$(cat)""'''"|nixfmt
    # >>>sh<<<
  '';
}
