{lib, ...}: {
  sops.roles = ["private"];
  nix.settings.substituters = lib.mkForce [
    "https://c.lackof.buzz"
    "https://emerge.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "emerge.cachix.org-1:Zvw8m0TXudK0MtylBFvUZCUEHlOfTgfvE2bbIexGhVw="
  ];
  networking.firewall.allowedTCPPortRanges = [{ from = 8000; to = 10000; }];
}
