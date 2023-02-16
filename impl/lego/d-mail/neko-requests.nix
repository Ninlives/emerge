{ config, var, ... }: {
  d-mail = config.home-manager.users.${config.workspace.user.name}.requestNixOSConfig;
}
