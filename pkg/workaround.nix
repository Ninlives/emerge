final: prev: {
  inherit
    (import (final.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "2d2a9ddbe3f2c00747398f3dc9b05f7f2ebb0f53";
      hash = "sha256-B5WRZYsRlJgwVHIV6DvidFN7VX7Fg9uuwkRW9Ha8z+w=";
    }) {inherit (final) system;})
    pcsclite
    ;
}
