{ lib, ... }: {
  nix.settings.substituters = lib.mkForce [
    "https://c.lackof.buzz"
  ];
  nix.settings.fallback = true;
}
