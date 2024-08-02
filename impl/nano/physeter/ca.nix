{lib, ...}: {
  system.activationScripts.update-ca-certs = lib.stringAfter ["etc"] ''
    mkdir -p /etc/ssl/ca-anchors
    cat /etc/ssl/certs/ca-certificates.crt > /etc/ssl/ca-anchors/ca-certificates.crt
    rm /etc/ssl/certs/ca-certificates.crt
    rm /etc/ssl/certs/ca-bundle.crt

    for cert in $(find /etc/ssl/ca-anchors -name '*.crt');do
      cat "$cert" >> /etc/ssl/certs/ca-certificates.crt
    done
    cp /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-bundle.crt
  '';

  revive.specifications.crux.boxes = [
    {
      src = /Data/ca-anchors;
      dst = /etc/ssl/ca-anchors;
    }
  ];
}
