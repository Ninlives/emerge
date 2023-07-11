{ config, lib, var, pkgs, inputs, ... }:
let
  inherit (config.home) homeDirectory;
  inherit (var) seal;
  inherit (lib.hm) dag;
  Home = p: {
    src = "/Home/${p}";
    dst = p;
  };
in {
  home.sessionVariables = {
    EDITOR = "vi";
    LESSHISTFILE = "${homeDirectory}/.local/less_history";
    RLWRAP_HOME = "${homeDirectory}/.local";
    KEYTIMEOUT = "1";
    NIX_AUTO_RUN = "!";
  };
  home.stateVersion = "20.09";

  home.extraOutputsToInstall = [ "doc" "info" "devdoc" ];

  persistent.boxes = map Home [
    "Desktop"
    "Documents"
    "Downloads"
    "Music"
    "Pictures"
    "Public"
    "Templates"
    "Videos"
  ] ++ [
    { src = /Programs/ssh; dst = ".ssh"; }
    # { src = /Programs/gnupg; dst = ".gnupg"; }
    { src = /Programs/wrapped; dst = ".local/fakefs"; }
    { src = /Programs/nix/data; dst = ".local/share/nix"; }
    { src = /Programs/nix/cache; dst = ".cache/nix"; }
    { src = /Programs/nix/index; dst = ".cache/nix-index"; }
    { src = /Programs/nix/state; dst = ".local/state/nix"; }
  ];

  home.activation.scratch = dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${homeDirectory}/Scratch
  '';
}
