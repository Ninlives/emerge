{ fn, var, lib, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    promptInit = "";
  };

  programs.adb.enable = true;
  users.users.${var.user.name}.extraGroups = [ "adbusers" ];
  nixpkgs.config.android_sdk.accept_license = true;
  revive.specifications.user.boxes = [{
    src = /Programs/adb;
    dst = fn.home ".android";
  }];

  environment.systemPackages = with pkgs; [
    git
    git-crypt
    openconnect
    zip
    unrar
    unzip
    ntfs3g
    exfat
  ];
}
