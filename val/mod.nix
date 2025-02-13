{
  fn,
  lib,
  inputs,
  ...
}:
with lib;
with inputs; {
  flake.mod = {
    bombe = {
      imports = [
        sops-nix.nixosModules.sops
        ../bombe
      ];
    };
    opt = listToAttrs (map (o: {
      name = removeSuffix ".nix" (baseNameOf o);
      value = o;
    }) (fn.dotNixFrom ../opt));
    impl.lego = listToAttrs (map (o: {
      name = baseNameOf o;
      value = let
        pat = partition (m: hasSuffix ".h" m || hasSuffix ".h.nix" m) (fn.dotNixFromRecursive o);
      in
        {config, ...}:
          {
            imports = pat.wrong ++ (optional (pat.right != []) home-manager.nixosModule);
          }
          // (optionalAttrs (pat.right != []) {
            home-manager.users.${config.profile.user.name} = {...}: {
              imports = pat.right;
            };
          });
    }) (fn.filesFrom ../impl/lego));
    impl.neko = {imports = fn.dotNixFromRecursive ../impl/neko;};
    impl.echo = import ../impl/echo;
    impl.nano = {imports = fn.dotNixFromRecursive ../impl/nano;};
    impl.acro = {imports = fn.dotNixFromRecursive ../impl/acro;};
  };
}
