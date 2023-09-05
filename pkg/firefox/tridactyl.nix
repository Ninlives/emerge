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
    rev = "5cbfb728bd185535383bfb4e15966cfa2730b06d";
    sha256 = "11a32zsizdh47y7slzrd21vidyprh5677i7jnj10dpnrw2gs7sjy";
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
