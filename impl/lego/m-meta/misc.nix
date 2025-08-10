{
  self,
  pkgs,
  config,
  specialArgs,
  ...
}: {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = specialArgs;

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
  programs.zsh = {
    enable = true;
    promptInit = "";
  };

  sops.secrets.hashed-password.neededForUsers = true;

  nixpkgs.overlays = self.overlays';
}
