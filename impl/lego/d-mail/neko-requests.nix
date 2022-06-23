{ config, var, ... }: {
  d-mail = config.home-manager.users.${var.user.name}.requestNixOSConfig;
}
