{...}: {
  environment.sessionVariables.SSH_AUTH_SOCK = "/tmp/resign.ssh";
  nix.envVars.SSH_AUTH_SOCK = "/tmp/resign.ssh";
}
