{
  fetchFromGitHub,
  stdenv,
  python3,
  nodejs,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tridactyl";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "tridactyl";
    repo = "tridactyl";
    rev = "1280ad682bac83a3b4a2531195414cc1420f525d";
    sha256 = "0w13aimcxd03arbag7ivb089dmj8w8ffwbwqqjz450f51csyl2dv";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-TxUkHt5KUMkXzwIYRM3HKIbkjwIGCQtd1vPwI/IklXE=";
  };

  nativeBuildInputs = [
    python3
    nodejs
    yarnConfigHook
    yarnBuildHook
  ];

  preBuild = ''
    patchShebangs .
    mkdir .build_cache
    echo '<a href="https://github.com/tridactyl/tridactyl/graphs/contributors">Tridactyl Contributors</a>' > .build_cache/authors
  '';

  postBuild = ''
    yarn make-zip
  '';

  installPhase = ''
    install -v -D -m644 web-ext-artifacts/*.zip $out/share/mozilla/extensions/${finalAttrs.pname}.xpi
  '';
})
