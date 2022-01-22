{ config, lib, pkgs, alpha-world-line, out-of-world, ... }:
let
  inherit (pkgs) yubico-pam;
  inherit (out-of-world) dirs;
  inherit (lib) mkForce foldl;
  inherit (builtins) appendContext getContext;

  crpath = "/var/lib/yubico";
  yubico-rule = control:
    "auth ${control} ${yubico-pam}/lib/security/pam_yubico.so mode=challenge-response chalresp_path=${crpath}";

  pam-service-config = alpha-world-line.security.pam.services;

  patched-pam-text = lib.mapAttrs (service: config:
    let
      inserted-rule = if service == "login" then
        yubico-rule "required"
      else
        yubico-rule "sufficient";
      patched-text = pkgs.runCommandLocal "${service}-pam" {
        passAsFile = [ "text" ];
        inherit (config) text;
      } ''
        # <<<sh>>>
        cat $textPath > $out
        if grep -q 'auth required pam_unix\.so' $out; then
          sed -i '/auth required pam_unix\.so/i ${inserted-rule}' $out
        elif grep -q 'auth sufficient pam_unix\.so' $out; then
          sed -i '/auth sufficient pam_unix\.so/i ${inserted-rule}' $out
        fi
        # >>>sh<<<
      '';
      result = appendContext (builtins.readFile patched-text)
        (getContext (toString patched-text));
    in { text = mkForce result; }) pam-service-config;
in {
  security.pam.services = patched-pam-text;
  revive.specifications.with-snapshot.boxes = [ crpath ];
}
