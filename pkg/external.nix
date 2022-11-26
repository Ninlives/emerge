{ inputs, ... }:
final: prev:
inputs.external.overlay final prev // {
  deskreen = with final;
    let
      src = appimageTools.extract {
        name = "deskreen";
        src = fetchurl {
          url =
            "https://github.com/pavlobu/deskreen/releases/download/v2.0.3/Deskreen-2.0.3.AppImage";
          sha256 = "sha256-mtqBR46q63t+hnZUBGnLLJ0P6yRVEsNleCi95kF8Pno=";
        };
      };
      run = appimageTools.wrapAppImage {
        name = "deskreen";
        inherit src;
        extraPkgs = p: [ ];
      };
    in runCommand "deskreen" { } ''
      mkdir -p $out/share/applications
      ${xorg.lndir}/bin/lndir ${run} $out
      ${xorg.lndir}/bin/lndir ${src}/usr/share $out/share
      
      cp --no-preserve=all ${src}/deskreen.desktop $out/share/applications
      sed -i 's#Exec=.*#Exec=${placeholder "out"}/bin/deskreen#' $out/share/applications/deskreen.desktop
    '';
}
