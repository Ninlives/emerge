{ lib }: {
  allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "android-studio-stable" ];
}
