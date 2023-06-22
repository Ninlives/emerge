{ config, ... }: {
  networking.hostName = config.workspace.hostname;
  networking.networkmanager.enable = true;
}
