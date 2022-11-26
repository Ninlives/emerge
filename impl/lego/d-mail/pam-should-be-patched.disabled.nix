{ config, lib, pkgs, ... }:
{
  d-mail.pam-should-be-patched = alpha-world-line:
    let
      inherit (pkgs) pam_u2f;
      inherit (lib) mkIf mkForce foldl;
      inherit (builtins) appendContext getContext;
      scrt = config.sops.secrets;

      crpath = "/var/lib/yubico";
      yubico-rule = control:
        "auth ${control} ${pam_u2f}/lib/security/pam_u2f.so authfile=${scrt.u2f.path} origin=pam://mlatus appid=pam://auth cue";

      pam-service-config = alpha-world-line.config.security.pam.services;

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
    in { security.pam.services = patched-pam-text; };
}
