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
        opt.profile
        impl.lego.meta
        impl.lego.gnome-basic
        ./kexec-hat.nix
        ./fstab.nix
        ./config.nix
        ./ca.nix
        ./tasks/update-reservations
        ../network.nix
        ../mvlink.nix
      ];
    })
    .config
    .system
    .build;
}
