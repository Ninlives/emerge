{ config, pkgs, lib, ... }: {
  programs.chromium = {
    enable = true;
    extensions = [
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
      "padekgcemlokbadohgkifijomclgjgif" # Proxy SwitchyOmega
      "aikflfpejipbpjdlfabpgclhblkpaafo" # WeTab
    ];
  };
  environment.systemPackages = [ (pkgs.ungoogled-chromium.override { commandLineArgs = lib.concatStringsSep " " [
    "--disable-search-engine-collection"
    "--fingerprinting-canvas-image-data-noise"
    "--fingerprinting-canvas-measuretext-noise"
    "--fingerprinting-client-rects-noise"
    "--enable-features=DisableLinkDrag"
  ]; }) ];

  revive.specifications.user.boxes = [{
    src = /Programs/chromium;
    dst = "${config.workspace.user.home}/.config/chromium";
  }];
}
