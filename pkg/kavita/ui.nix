{ fetchurl }:
fetchurl {
  url = "https://github.com/Kareadita/Kavita/releases/download/v0.6.1/kavita-linux-x64.tar.gz";
  hash = "sha256-0/wycYBHQ4S6G3LdIj1YhRkH8QIE9F471QKcBSIning=";
  downloadToTemp = true;
  recursiveHash = true;
  postFetch = ''
    extracted=$(mktemp -d)
    tar xf $downloadedFile --directory=$extracted
    mkdir -p $out
    cp -R $extracted/Kavita/wwwroot/. $out/.
  '';
}
