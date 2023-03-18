{ config, lib, var, ... }: {
  sops.age.keyFile = "/${config.workspace.disk.persist}/System/Data/sops/age.key";
}
