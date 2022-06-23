{ lib, var }: import ./file.nix { inherit lib var; } // import ./builder.nix { inherit lib var; }
