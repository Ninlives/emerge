{ ... }: {
  imports = [
    ../../opt/rathole.nix
    ../coco/immich.nix
    ../coco/network.nix
    ../coco/nfs.nix
    ../taco/tunnels.nix
    ../taco/user.nix
  ];
  services.logind.lidSwitch = "lock";
  sops.profiles = [ "home" ];
}
