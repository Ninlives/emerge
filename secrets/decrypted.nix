{ lib, ... }: {
  secrets.decrypted = lib.recursiveUpdate (import ./encrypt) { ssh.auth = ""; };
}
