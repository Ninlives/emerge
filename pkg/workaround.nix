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

  tdesktop =
    final.runCommandLocal "tdesktop" {
      nativeBuildInputs = [final.makeWrapper];
    } ''
      mkdir -p $out
      ${final.xorg.lndir}/bin/lndir ${prev.tdesktop} $out
      wrapProgram $out/bin/telegram-desktop \
        --set QT_SCREEN_SCALE_FACTORS 2 \
        --set QT_QPA_PLATFORM xcb
    '';

  bluez-steamos = with final;
    bluez.overrideAttrs (o: {
      patches =
        o.patches
        or []
        ++ [
          (runCommandLocal "bluez.patch" {
              src = fetchFromGitHub {
                owner = "Jovian-Experiments";
                repo = "PKGBUILDs-mirror";
                rev = "e545ebcc3cb45fe391eeb1a384015bc84973b155";
                sha256 = "sha256-nYBnc34QmaRHuBVeWKAO3o5Uc2LIpU+U27HVoAg/Qyc=";
              };
            } ''
              cat $src/*.patch > $out
            '')
        ];
    });
}
