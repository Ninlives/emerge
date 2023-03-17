{ fn, var, lib, pkgs, config, ... }: {
  programs.zsh = {
    enable = true;
    promptInit = "";
  };

  programs.adb.enable = true;
  users.users.${config.workspace.user.name}.extraGroups = [ "adbusers" ];
  nixpkgs.config.android_sdk.accept_license = true;
  revive.specifications.user.boxes = [{
    src = /Programs/adb;
    dst = "${config.workspace.user.home}/.android";
  }];

  environment.systemPackages = with pkgs; [
    git
    git-crypt
    openconnect
    zip
    unzip
    ntfs3g
    exfat
  ];
}
