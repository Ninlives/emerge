{ pkgs, inputs, lib, ... }: {
  system.activationScripts.splash = lib.noDepEntry ''
    ${pkgs.coreutils}/bin/cat ${inputs.data.content.resources "splash.txt"} 
  '';
  system.activationScripts.setupSecretsForUsers.deps = [ "splash" ];
}
