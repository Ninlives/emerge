{ inputs, nixosConfig, pkgs, lib, config, ... }:
with lib;
let
  defAct = nixosConfig.workspace.email.account.default;
  email = inputs.values.secret.email.${defAct};
  getpass = item: "${pkgs.bitwarden-cli-wrapper}/bin/bw get password ${item}";
  mainAct = config.accounts.email.accounts.main;
  mailfilter = pkgs.writeText "mailfilter" ''
    to "${mainAct.maildir.absPath}/${mainAct.folders.inbox}"
  '';
in {
  home.packages = mkIf email.imap.enable [ pkgs.getmail6 ];
  programs.msmtp.enable = mkIf email.smtp.enable true;
  accounts.email = {
    maildirBasePath = "${config.home.homeDirectory}/Documents/Mail";
    accounts.main = {
      primary = true;
      realName = email.name;
      address = email.address;
      maildir.path = defAct;
      imap = mkIf email.imap.enable {
        inherit (email.imap) host port;
        userName = email.imap.user;
        passwordCommand = getpass email.imap.vaultItem;
      };
      smtp = mkIf email.smtp.enable {
        inherit (email.smtp) host port;
        userName = email.smtp.user;
        passwordCommand = getpass email.smtp.vaultItem;
      };
      getmail = mkIf email.imap.enable {
        enable = true;
        mailboxes = [ "ALL" ];
        delete = true;
        destinationCommand = "${pkgs.maildrop}/bin/maildrop";
      };
      msmtp = mkIf email.smtp.enable { enable = true; };
      neomutt = mkIf email.imap.enable { enable = true; };
    };
  };

  home.activation.mkMails = mkIf email.imap.enable
    (hm.dag.entryAfter [ "writeBoundary" ] (''
      (umask 0077; cat ${mailfilter} > ${config.home.homeDirectory}/.mailfilter)
      mkdir -p ${mainAct.maildir.absPath}
    '' + concatMapStringsSep "\n" (folder: ''
      if [[ ! -d "${mainAct.maildir.absPath}/${folder}" ]];then
        ${pkgs.maildrop}/bin/maildirmake "${mainAct.maildir.absPath}/${folder}"
      fi
    '') (filter isString (attrValues mainAct.folders))));
}
