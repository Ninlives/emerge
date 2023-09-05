{pkgs}:
with pkgs;
  haskellPackages.shellFor {
    packages = p: [(callPackage ./default.nix {})];
    withHoogle = true;
    # nativeBuildInputs = [ hie wrappedVi ];
    shellHook = ''
      export HIE_HOOGLE_DATABASE="$NIX_GHC_LIBDIR/../../share/doc/hoogle/index.html"
    '';
  }
