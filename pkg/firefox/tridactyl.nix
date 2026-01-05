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
    rev = "1280ad682bac83a3b4a2531195414cc1420f525d";
    sha256 = "0w13aimcxd03arbag7ivb089dmj8w8ffwbwqqjz450f51csyl2dv";
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
