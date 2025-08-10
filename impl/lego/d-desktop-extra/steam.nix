{ config, pkgs, ... }: {
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.steam.package = pkgs.steam.override { extraEnv = { MANGOHUD = true; }; };
  revive.specifications.user.boxes =
    [
      {
        src = /Programs/steam/data;
        dst = "${config.profile.user.home}/.local/share/Steam";
      }
      {
        src = /Programs/steam/dot;
        dst = "${config.profile.user.home}/.steam";
      }
    ];
}
