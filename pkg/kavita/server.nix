{ buildDotnetModule, fetchFromGitHub, dotnet-aspnetcore }:
buildDotnetModule {
  pname = "Kavita";
  version = "0.6.1";
  src = fetchFromGitHub {
    owner = "Kareadita";
    repo = "Kavita";
    rev = "f907486c74592104dc9511cf5bf8ecbedfbe4ccb";
    sha256 = "sha256-Wuy/ypYUb33KfzFCGV+0b9xrXomlIjq3JTa9sndS2ng=";
  };

  nugetDeps = ./nuget-deps.nix;
  executables = [ "API" ];
  dotnet-runtime = dotnet-aspnetcore;
  postFixup = ''
    mv $out/bin/API $out/bin/Kavita
  '';
}
