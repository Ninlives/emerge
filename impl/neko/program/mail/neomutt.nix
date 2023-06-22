{ inputs, nixosConfig, lib, ... }:
with lib;
let
  email =
    inputs.values.secret.email.${nixosConfig.workspace.email.account.default};
in {
  programs.neomutt = {
    enable = mkIf email.imap.enable true;
    vimKeys = true;
  };
}
