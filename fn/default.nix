{ lib, var, pkgs }: import ./file.nix { inherit lib var pkgs; } // import ./builder.nix { inherit lib var; }
