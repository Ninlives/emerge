{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}: {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = specialArgs;

  system.nixos.tags = [config.boot.kernelPackages.kernel.version];
  system.nixos.label = with lib;
    concatStringsSep "-" ([config.profile.identity]
      ++ (sort (x: y: x < y) config.system.nixos.tags));

  time.timeZone = "Asia/Shanghai";
  users.mutableUsers = false;
  users.users.${config.profile.user.name} = {
    inherit (config.profile.user) uid home;
    shell = pkgs.zsh;
    createHome = true;
    isNormalUser = true;
    extraGroups = ["pulseaudio" "audio" "video" "power" "wheel" "networkmanager"];
    hashedPasswordFile = config.sops.secrets.hashed-password.path;
  };
  sops.secrets.hashed-password.neededForUsers = true;

  system.stateVersion = "22.05";
}
