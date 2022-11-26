{ buildDotnetModule, fetchFromGitHub, dotnet-aspnetcore }:
buildDotnetModule {
  pname = "Kavita";
  version = "0.5.6";
  src = fetchFromGitHub {
    owner = "Kareadita";
    repo = "Kavita";
    rev = "e649f5cf9dadf8dfb869d538f2c9e8fd36ef823f";
    sha256 = "sha256-U5hIpQon+cWDZUccSj31/rpqNvS5pO9+seFuCxy236Q=";
  };

  nugetDeps = ./nuget-deps.nix;
  executables = [ "API" ];
  dotnet-runtime = dotnet-aspnetcore;
  postFixup = ''
    mv $out/bin/API $out/bin/Kavita
  '';
}
