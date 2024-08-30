{
  fetchFromGitHub,
  mkYarnModules,
  stdenv,
  python3,
  nodejs,
  yarn,
}: let
  src = fetchFromGitHub {
    owner = "tridactyl";
    repo = "tridactyl";
    rev = "eb1141b8c89472225a45c8c2d39cc8bc2ab26ee5";
    sha256 = "0n87fddlxbnd9lw4y0a8g8vx7rz7j5rpzdmd473pcc8vj77r5nbs";
  };
  deps = mkYarnModules {
    pname = "tridactyl-modules";
    version = "unstable";
    packageJSON = src + "/package.json";
    yarnLock = src + "/yarn.lock";
  };
in
  stdenv.mkDerivation rec {
    pname = "tridactyl";
    version = "unstable";
    inherit src deps;
    nativeBuildInputs = [python3 nodejs yarn];

    configurePhase = ''
      patchShebangs .
      cp -r ${deps}/node_modules node_modules
      chmod -R +w node_modules
    '';

    buildPhase = ''
      mkdir .build_cache
      echo '<a href="https://github.com/tridactyl/tridactyl/graphs/contributors">Tridactyl Contributors</a>' > .build_cache/authors
      yarn run build
      yarn run make-zip
    '';

    installPhase = ''
      install -v -D -m644 web-ext-artifacts/*.zip $out/share/mozilla/extensions/${pname}.xpi
    '';
  }
