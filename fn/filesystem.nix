{lib}:
with lib; let
  # data PathT = PathT { path :: Path, type :: String }
  # listFiles :: Path -> [PathT]
  listFiles = dir:
    mapAttrsToList (name: type: {
      inherit type;
      path = childUnder dir name;
    }) (builtins.readDir dir);

  # filterFiles :: Path -> [PathT -> Bool] -> [PathT]
  filterFiles = dir: filters: pipe (listFiles dir) (map filter filters);

  # filterFilesRecursive :: Path -> [PathT -> Bool] -> [PathT -> Bool] -> [PathT]
  filterFilesRecursive = dir: keepFilters: expFilters: let
    keep = filterFiles dir keepFilters;
    exp = filterFiles dir expFilters;
  in
    keep
    ++ concatLists
    (map (p: filterFilesRecursive p.path keepFilters expFilters) exp);

  # filesFromWith :: Path -> [PathT -> Bool] -> [Path]
  filesFromWith = dir: filters: catAttrs "path" (filterFiles dir filters);

  # filesFromWithRecursive :: Path -> [PathT -> Bool] -> [PathT -> Bool] -> [Path]
  filesFromWithRecursive = dir: keepFilters: expFilters:
    catAttrs "path" (filterFilesRecursive dir keepFilters expFilters);

  # filesFrom :: Path -> [Path]
  filesFrom = dir: filesFromWith dir [(_: true)];

  # childUnder :: Path -> String -> Path
  childUnder = dir: name: dir + "/${name}";

  # defNix :: Path -> Path
  defNix = dir: childUnder dir "default.nix";

  # disabledFilter :: PathT -> Bool
  disabledFilter = f:
    !(f.type == "regular" && hasSuffix ".disabled.nix" f.path)
    && !(f.type == "directory" && hasSuffix ".disabled" f.path);

  # dotNixFilter :: PathT -> Bool
  dotNixFilter = f:
    (f.type == "regular" && hasSuffix ".nix" f.path)
    || (f.type == "directory" && pathExists (defNix f.path));

  # defNixFilter :: PathT -> Bool
  defNixFilter = f: f.type == "directory" && !(pathExists (defNix f.path));

  # dotNixFrom :: Path -> [Path]
  dotNixFrom = dir: filesFromWith dir [disabledFilter dotNixFilter];

  # dotNixFromRecursive :: Path -> [Path]
  dotNixFromRecursive = dir:
    filesFromWithRecursive dir [disabledFilter dotNixFilter] [
      disabledFilter
      defNixFilter
    ];
in {
  inherit
    filesFromWith
    filesFromWithRecursive
    filesFrom
    dotNixFrom
    dotNixFromRecursive
    disabledFilter
    dotNixFilter
    defNixFilter
    ;
}
