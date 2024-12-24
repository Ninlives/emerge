final: prev: {
  nixMeta = final.nixVersions.latest;
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
