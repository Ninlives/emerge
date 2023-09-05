{config, ...}: {
  sops.age.keyFile = "/${config.profile.disk.persist}/System/Data/sops/age.key";
}
