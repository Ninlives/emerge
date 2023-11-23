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
}
