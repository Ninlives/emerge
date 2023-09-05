{config, ...}: {
  programs.zsh = {
    enable = true;
    promptInit = "";
  };

  programs.adb.enable = true;
  users.users.${config.profile.user.name}.extraGroups = ["adbusers"];
  nixpkgs.config.android_sdk.accept_license = true;
  revive.specifications.user.boxes = [
    {
      src = /Programs/adb;
      dst = "${config.profile.user.home}/.android";
    }
  ];
  networking.networkmanager.enable = true;
}
