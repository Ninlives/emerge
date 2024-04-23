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
  nixVersions =
    prev.nixVersions
    // {
      stable = prev.nixVersions.stable.overrideAttrs (p: {
        prePatch = p.prePatch or "" + /* bash */ ''
          # Adapt second patch
          sed -i -e 's/nix show-config/nix config show/g' tests/functional/experimental-features.sh
        '';
        postPatch = p.postPatch or "" + /* bash */ ''
          sed -i -e 's/nix config show/nix show-config/g' tests/functional/experimental-features.sh
        '';
        patches =
          p.patches
          or []
          ++ [
            (final.writeText "adapt.patch" /* diff */ ''
              --- a/src/libutil/config.cc
              +++ b/src/libutil/config.cc
              @@ -85,7 +83,7 @@
               
               void Config::getSettings(std::map<std::string, SettingInfo> & res, bool overriddenOnly)
               {
              -    for (auto & opt : _settings)
              +    for (const auto & opt : _settings)
                       if (!opt.second.isAlias && (!overriddenOnly || opt.second.setting->overridden))
                           res.emplace(opt.first, SettingInfo{opt.second.setting->to_string(), opt.second.setting->description});
               }
            '')
            (final.fetchpatch {
              url = "https://github.com/NixOS/nix/commit/94e91566ed7f1df778468862204e7495a3f0f001.patch";
              hash = "sha256-ZS2uwVPiW2+H59LIltz6P4vo944BZSLSQkveCg5WagU=";
            })
            (final.fetchpatch {
              url = "https://github.com/NixOS/nix/commit/78e7c98b0253062549dd4d0f107a1525bbcff38c.patch";
              hash = "sha256-K/5rkNX0/chWQTCrOXi0Ez7KqGu+dGYvTXk09KfhRL4=";
            })
          ];
      });
    };
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
