{ config, pkgs, ... }: {
  programs.chromium = {
    enable = true;
    extensions = [
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
      "padekgcemlokbadohgkifijomclgjgif" # Proxy SwitchyOmega
    ];
  };
  environment.systemPackages = [ pkgs.chromium ];

  revive.specifications.user.boxes = [{
    src = /Programs/chromium;
    dst = "${config.workspace.user.home}/.config/chromium";
  }];
}