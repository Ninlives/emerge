{ pkgs, inputs, ... }: {
  sops.extendScripts.pre-sops = ''
    ${pkgs.coreutils}/bin/cat ${inputs.data.content.resources "splash.txt"} 
  '';
}
