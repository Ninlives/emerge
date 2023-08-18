{ lib, config, pkgs, inputs, nixosConfig, ... }:
let
  monitor-src = "${nixosConfig.revive.specifications.user.seal}/Programs/misc/monitors.xml";
  monitor-dst = "${config.home.homeDirectory}/.config/monitors.xml";
  cat = "${pkgs.coreutils}/bin/cat";
  mkdir = "${pkgs.coreutils}/bin/mkdir";
in {

  home.file.".face".source = inputs.data.content.resources "avatar.jpg";

  home.activation.setup-monitor = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${mkdir} -p ${dirOf monitor-src}
    if [[ -f "${monitor-src}" ]];then
      ${mkdir} -p ${dirOf monitor-dst}
      ${cat} ${monitor-src} > ${monitor-dst}
    fi
  '';
  job.cleanup = ''
    if [[ -f "${monitor-dst}" ]];then
      ${cat} ${monitor-dst} > ${monitor-src}
    fi
  '';
}
