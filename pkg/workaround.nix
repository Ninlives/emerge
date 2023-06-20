{ ... }:
final: prev: {
  gnomeExtensions = prev.gnomeExtensions // {
    pixel-saver = prev.gnomeExtensions.pixel-saver.overrideAttrs (p: {
      preInstall = p.preInstall or "" + ''
        ${final.jq}/bin/jq -e '.["shell-version"] += ["44"]' < metadata.json | \
        ${final.moreutils}/bin/sponge metadata.json

        sed -e 's#/usr/bin/xprop#${final.xorg.xprop}/bin/xprop#' \
            -e "s#'xprop#'${final.xorg.xprop}/bin/xprop#" -i decoration.js
      '';
    });
  };

  gruvbox-gtk-theme = prev.gruvbox-gtk-theme.overrideAttrs (p: {
    src = 
      assert p.src.outputHash
        == "1411mjlcj1d6kw3d3h1w9zsr0a08bzl5nddkkbv7w7lf67jy9b22";
      final.fetchFromGitHub {
        owner = "Fausto-Korpsvart";
        repo = "Gruvbox-GTK-Theme";
        rev = "4bb3a07088c93d53e621658791495b0aa7f80fce";
        sha256 = "0p9gk47v0910z3dlfbsb0s3jab6jiwpxj7pzv2jk1j727sjyh85d";
      };
  });

  # alsa-ucm-conf = prev.alsa-ucm-conf.overrideAttrs (p: {
  #   src = assert p.src.outputHash == "sha256-N09oM7/XfQpGdeSqK/t53v6FDlpGpdRUKkWWL0ueJyo=";
  #     final.fetchurl {
  #       url = "mirror://alsa/lib/alsa-ucm-conf-1.2.8.tar.bz2";
  #       hash = "sha256-/uSnN4MP0l+WnYPaRqKyMb6whu/ZZvzAfSJeeCMmCug=";
  #     };
  # });

  # tdesktop = final.runCommandLocal "tdesktop" {
  #   nativeBuildInputs = [ final.makeWrapper ];
  # } ''
  #   mkdir -p $out
  #   ${final.xorg.lndir}/bin/lndir ${prev.tdesktop} $out
  #   wrapProgram $out/bin/telegram-desktop \
  #     --set QT_SCREEN_SCALE_FACTORS 2 \
  #     --set QT_QPA_PLATFORM xcb
  # '';
}
