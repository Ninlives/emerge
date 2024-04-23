{
  pkgs,
  config,
  ...
}: let
  set-session = with pkgs;
    python3.pkgs.buildPythonApplication {
      name = "set-session";
      format = "other";

      src = ./set-session.py;

      dontUnpack = true;
      strictDeps = false;

      nativeBuildInputs = [wrapGAppsHook gobject-introspection];
      buildInputs = [accountsservice glib];
      propagatedBuildInputs = with python3.pkgs; [pygobject3 ordered-set];

      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/set-session
        chmod +x $out/bin/set-session
      '';
    };
  systemctl = "${config.systemd.package}/bin/systemctl";
in {
  jovian.steam.enable = true;
  users.users.deck = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "input"];
    hashedPasswordFile = config.sops.secrets.hashed-password-deck.path;
    home = "/home/deck";
    createHome = true;
    uid = 1001;
  };
  sops.secrets.hashed-password-deck.neededForUsers = true;
  home-manager.users.deck.home = {
    stateVersion = "22.05";
    packages = with pkgs; [steam];
  };

  services.displayManager.job.preStart = "${set-session}/bin/set-session";
  environment.etc."gdm/PreSession/Default".source = pkgs.writeShellScript "presession" ''
    if [[ "$USERNAME" = "deck" ]];then
      ${config.lib.commands.speech} || true
      ${systemctl} stop opensd.service || true
    fi
  '';
  environment.etc."gdm/PostSession/Default".source = pkgs.writeShellScript "postsession" ''
    ${config.lib.commands.speechless} || true
    ${systemctl} start opensd.service || true
  '';

  revive.specifications.deck = {
    seal = "/plateau/Deck";
    user = config.users.users.deck.name;
    group = config.users.groups.users.name;
  };
  fileSystems."/plateau".neededForBoot = true;
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
}
