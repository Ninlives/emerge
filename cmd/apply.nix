{
  fn,
  self,
  ...
}: {
  perSystem = {pkgs, ...}: {
    apps.apply = with pkgs;
      fn.mkApp {
        drv = let
          toplevel = self.nixosConfigurations.holo.config.system.build.toplevel;
        in
          writeShellScriptBin "apply" ''
            if [[ $1 == "build" ]];then
              echo "Build finished"
            else
              if [[ $1 != "test" ]];then
                sudo ${nixMeta}/bin/nix-env -p /nix/var/nix/profiles/system --set ${toplevel}
              fi
              exec sudo ${toplevel}/bin/switch-to-configuration "$@"
            fi
          '';
      };
  };
}
