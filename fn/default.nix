{ lib, var }: import ./file.nix { inherit lib var; } // import ./trivial.nix { inherit lib var; }
