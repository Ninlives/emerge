{
  lib,
  config,
  ...
}: {
  nix.settings.substituters = lib.mkForce [
    "https://c.lackof.buzz"
  ];
  nix.settings.fallback = true;
  # Prefix with ! to bypass validation
  nix.extraOptions = ''
    !include ${config.sops.templates.impure-env-conf.path}
  '';
  sops.templates.impure-env-conf.content = ''
    impure-env = NIX_GITHUB_PRIVATE_USERNAME=Ninlives NIX_GITHUB_PRIVATE_PASSWORD=${config.sops.placeholder.github}
  '';
}
