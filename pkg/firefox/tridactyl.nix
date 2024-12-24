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
    rev = "4ec92541113a78d64942594f506997fb3a53106e";
    sha256 = "0vnik8p6f5asp38z6pxvl5pw7p1rqyiydswwza8nldx9ly3pd99q";
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
