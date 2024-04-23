final: prev: {
  gnomeExtensions =
    prev.gnomeExtensions
    // {
      pixel-saver = prev.gnomeExtensions.pixel-saver.overrideAttrs (p: {
        preInstall =
          p.preInstall
          or ""
          + ''
            ${final.jq}/bin/jq -e '.["shell-version"] += ["44"]' < metadata.json | \
            ${final.moreutils}/bin/sponge metadata.json

            sed -e 's#/usr/bin/xprop#${final.xorg.xprop}/bin/xprop#' \
                -e "s#'xprop#'${final.xorg.xprop}/bin/xprop#" -i decoration.js
          '';
      });
    };
  nixMeta = final.nixVersions.unstable;
  inherit
    (import (final.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "ff323ed355ff62795c79c3fed04c4ee06c641898";
      hash = "sha256-QVeaHxwSjYZgEeklNFuWx1mMgG6zyfEFRW+2vnxV2FU=";
    }) {inherit (final) system;})
    v2ray
    ;
}
