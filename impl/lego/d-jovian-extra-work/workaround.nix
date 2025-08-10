{...}: {
  nixpkgs.overlays = [
    (final: prev: {
      wpa_supplicant = prev.wpa_supplicant.overrideAttrs (p: {
        patches = p.patches or [] ++ [./wpa_legacy_server_connect.patch];
      });
    })
  ];

  services.xserver.config = ''
    Section "Extensions"
        Option "MIT-SHM" "Disable"
    EndSection
  '';
}
