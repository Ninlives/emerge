{
  fn,
  inputs,
  pkgs,
  self,
  args,
  ...
}: {
  system.build.physeter =
    (inputs.nixpkgs.lib.nixosSystem {
      inherit (pkgs) system;
      specialArgs = {inherit fn self inputs args;};
      modules = with self.mod; [
        inputs.home-manager.nixosModule
        bombe
        opt.revive
        opt.sops
        ./kexec-hat.nix
        ./fstab.nix
        ./config.nix
        ../network.nix
        ../mvlink.nix
      ];
    })
    .config
    .system
    .build
    .kexecHat;
}
