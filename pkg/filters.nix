{ var, inputs, ... }:
final: prev:
with final;
with inputs;
with final.lib;
let
  mkFilter = name: action:
    writeShellScriptBin name ''
      set -e
      export PATH=${
        makeBinPath [ sops nix nixfmt coreutils findutils gawk age jq ]
      }
      export SOPS_AGE_RECIPIENTS="age1z45qh5zan89fy9swamy40rrvsnragat4jsuerl8ufk7fq5kl43mstre7m3"
      export SOPS_AGE_KEY_FILE="$HOME/Secrets/keys/git/age.key"
      ${action}
    '';
in {
  sops-git-filter-clean = mkFilter "sops-git-filter-clean" /* bash */ ''
    content=$(cat)
    if [[ $(nix eval --expr 'builtins.hasAttr "sops" '"$content") == 'true' ]];then
      echo "$content"|nixfmt
    else
      nix eval --json --expr "$content"|\
      sops --input-type json --output-type json -e /dev/stdin|\
      nix eval --expr "builtins.fromJSON '''""$(cat)""'''"|\
      nixfmt
    fi
  '';
  sops-git-filter-smudge = mkFilter "sops-git-filter-smudge" /* bash */ ''
    content=$(cat)
    if [[ $(nix eval --expr 'builtins.hasAttr "sops" '"$content") == 'true' ]];then
      nix eval --json --expr "$content"|\
      sops --input-type=json --output-type=json -d /dev/stdin|\
      nix eval --expr "builtins.fromJSON '''""$(cat)""'''"|\
      nixfmt
    else
      echo $content|nixfmt
    fi
  '';
}
