{config, pkgs, ...}: {
  environment.systemPackages = [ pkgs.android-tools ];
  nixpkgs.config.android_sdk.accept_license = true;
  revive.specifications.user.boxes = [
    {
      src = /Programs/adb;
      dst = "${config.profile.user.home}/.android";
    }
  ];
  networking.networkmanager.enable = true;
}
