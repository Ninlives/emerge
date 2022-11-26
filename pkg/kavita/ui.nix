{ fetchurl }:
fetchurl {
  url = "https://github.com/Kareadita/Kavita/releases/download/v0.5.6/kavita-linux-x64.tar.gz";
  hash = "sha256-twjJbair8ILWEMkCivTm4qqxSt1v074FCGPCLHlVlJo=";
  downloadToTemp = true;
  recursiveHash = true;
  postFetch = ''
    extracted=$(mktemp -d)
    tar xf $downloadedFile --directory=$extracted
    mkdir -p $out
    cp -R $extracted/Kavita/wwwroot/. $out/.
  '';
}
