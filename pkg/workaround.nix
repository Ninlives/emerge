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
  # v2ray = prev.v2ray.override {
  #   buildGoModule = args:
  #     assert args.src.outputHash == "sha256-wiAK3dzZ9TGYkt7MmBkYTD+Mi5BEid8sziDM1nI3Z80="; (final.buildGo120Module (args
  #       // rec {
  #         version = "5.7.0";
  #         src = final.fetchFromGitHub {
  #           owner = "v2fly";
  #           repo = "v2ray-core";
  #           rev = "v${version}";
  #           hash = "sha256-gdDV5Cd/DjEqSiOF7j5a8QLtdJiFeNCnHoA4XD+yiGA=";
  #         };
  #         vendorHash = "sha256-uq0v14cRGmstJabrERsa+vFRX6Bg8+5CU6iV8swrL/I=";
  #       }));
  # };
}
