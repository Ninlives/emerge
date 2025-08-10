{
  pkgs,
  config,
  lib,
  ...
}: let
  steam-mount = with pkgs;
  with lib; let
    as-user = "${util-linux}/bin/runuser -u ${config.profile.user.name} -- ";
  in
    writeShellScript "steam-mount" ''
      set -e
      STEAM_DIR=$(${as-user} ${coreutils}/bin/mktemp -t -d steam.XXXXXXX)
      # FIXME hardcode path and uid
      ${as-user} ${coreutils}/bin/mkdir -p "$STEAM_DIR/"{deck,tavern}
      ${concatMapStringsSep "\n" (p: ''
        ${as-user} ${coreutils}/bin/mkdir -p "$STEAM_DIR/deck/.${strings.toLower p}"
        ${config.security.wrapperDir}/mount \
          --bind /plateau/Deck/${p} "$STEAM_DIR/deck/.${strings.toLower p}" \
          -o 'X-mount.idmap=u:1001:${
          toString config.profile.user.uid
        }:1 g:100:100:1'
      '') ["Local" "Config" "Steam"]}
      ${config.security.wrapperDir}/mount \
        --bind /tavern "$STEAM_DIR/tavern" \
        -o 'X-mount.idmap=u:1001:${
        toString config.profile.user.uid
      }:1 g:100:100:1'
      echo $STEAM_DIR
    '';
  launch-steam = with pkgs;
    writeShellScript "launch-steam" ''
      STEAM_DIR=$(${config.security.wrapperDir}/sudo ${steam-mount})
      exec ${bubblewrap}/bin/bwrap \
          --chdir "${config.profile.user.home}" \
          --dev-bind /dev /dev \
          --tmpfs /tmp \
          --proc /proc \
          --die-with-parent \
          --bind /sys /sys \
          --bind /nix /nix \
          --bind /etc /etc \
          --bind "$STEAM_DIR/tavern" /tavern \
          --bind "$STEAM_DIR/deck" "${config.profile.user.home}" \
          --bind /run/wrappers /run/wrappers \
          --bind /run/dbus /run/dbus \
          --bind /run/user /run/user \
          --bind /run/opengl-driver /run/opengl-driver \
          --bind /run/opengl-driver-32 /run/opengl-driver-32 \
          --bind /run/current-system /run/current-system \
          -- ${steam}/bin/steam "$@"
    '';
  steam-application = pkgs.runCommandLocal "steam-application" {} ''
    mkdir -p $out/{bin,share,share/applications}
    ln -s ${launch-steam} $out/bin/launch-steam
    for d in ${pkgs.steam}/share/*;do
      if [[ "$(basename "$d")" == "applications" ]];then
        continue
      fi
      ln -s "$(realpath "$d")" "$out/share/$(basename "$d")"
    done
    cat "${pkgs.steam}/share/applications/steam.desktop" \
      | sed -e 's#Exec=steam#Exec=${launch-steam}#' > $out/share/applications/steam.desktop
  '';
in {
  security.sudo.extraRules = [
    {
      users = [config.profile.user.name];
      commands = [
        {
          command = "${steam-mount}";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  allowUnfreePackageNames = ["steam" "steam-run" "steamdeck-hw-theme" "steam-jupiter-original"];
  environment.systemPackages = [steam-application];
}
