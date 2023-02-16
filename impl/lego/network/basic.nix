{ lib, config, ... }: {
  networking.hostName = config.workspace.hostName;
  networking.networkmanager.enable = true;
}
