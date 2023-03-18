{ lib, pkgs, fn, var, config, ... }:
let
  set-session = with pkgs;
    python3.pkgs.buildPythonApplication {
      name = "set-session";
      format = "other";

      src = ./set-session.py;

      dontUnpack = true;
      strictDeps = false;

      nativeBuildInputs = [ wrapGAppsHook gobject-introspection ];
      buildInputs = [ accountsservice glib ];
      propagatedBuildInputs = with python3.pkgs; [ pygobject3 ordered-set ];

      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/set-session
        chmod +x $out/bin/set-session
      '';
    };
in {
  config = lib.mkIf (config.workspace.identity == "private") {
    jovian.steam.enable = true;
    users.users.deck = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" ];
      hashedPassword = "";
      home = "/home/deck";
      createHome = true;
      uid = 1001;
    };
    services.xserver.displayManager.job.preStart =
      "${set-session}/bin/set-session";

    allowUnfreePackageNames = [
      "steam"
      "steam-run"
      "steamdeck-hw-theme"
      "steam-jupiter-original"
    ];

    revive.specifications.deck = {
      seal = "/${config.workspace.disk.persist}/Deck";
      user = config.users.users.deck.name;
      group = config.users.groups.users.name;
    };
    revive.specifications.deck.boxes = [
      {
        src = /Steam;
        dst = /home/deck/.steam;
      }
      {
        src = /Local;
        dst = /home/deck/.local;
      }
      {
        src = /Config;
        dst = /home/deck/.config;
      }
    ];
  };
}
