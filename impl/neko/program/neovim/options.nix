{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.types;
with lib.hm.types; let
  inherit (lib.hm) dag;
  inherit (builtins) filter;
  inherit (pkgs) vimPlugins callPackage makeWrapper runCommand;

  pluginSet = vimPlugins // (callPackage ./vim-packages {});

  pluginType = mkOptionType {
    name = "vim-plugins";
    description = "vim plugins";
    check = x:
      if isFunction x
      then isList (x pluginSet)
      else false;
    merge = mergeOneOption;
  };

  extraPythonPackageType = mkOptionType {
    name = "extra-python-packages";
    description = "python packages in python.withPackages format";
    check = x:
      if isFunction x
      then isList (x pkgs.python3Packages)
      else false;
    merge = mergeOneOption;
  };

  settings =
    (dag.topoSort
      (filterAttrs (n: v: v.data.enable) config.programs.neovim.settings))
    .result;

  normalConfig = concatMapStringsSep "\n" (v: ''
    " ${v.name}
    ${v.data.config}
    ${optionalString (v.data.lua != "") ''
      lua << EOLUA
      ${v.data.lua}
      EOLUA
    ''}
  '') (filter (v: v.data.config != "" || v.data.lua != "") settings);

  pythonPackages = p: flatten (map (v: v.data.pythonPackages p) settings);
  plugins = concatMap (v: v.data.plugins pluginSet) settings;
  extraPackages = concatMap (v: v.data.extraPackages) settings;

  wrapEnvironment = environment:
    mapAttrsToList (n: v: ''--set ${n} "${v}"'') environment;
  wrapArgs =
    concatStringsSep " \\\n"
    (flatten (map (v: wrapEnvironment v.data.environment) settings));

  gnvim = runCommand "gnvim" {buildInputs = [makeWrapper];} ''
    mkdir -p $out/bin
    makeWrapper ${pkgs.gnvim}/bin/gnvim $out/bin/gnvim \
      --add-flags '--nvim=${config.programs.neovim.finalPackage}/bin/nvim' \
      ${wrapArgs}
    ln -s ${pkgs.gnvim}/share $out/share
  '';
in {
  options.programs.neovim.settings = mkOption {
    type = dagOf (submodule ({
      config,
      name,
      ...
    }: {
      options = {
        enable = mkOption {
          type = bool;
          default = true;
        };

        plugins = mkOption {
          type = pluginType;
          default = plugins: [];
        };

        config = mkOption {
          type = lines;
          default = "";
        };

        lua = mkOption {
          type = lines;
          default = "";
        };

        extraPackages = mkOption {
          type = listOf package;
          default = [];
        };

        pythonPackages = mkOption {
          type = extraPythonPackageType;
          default = _: [];
        };

        environment = mkOption {
          type = attrsOf str;
          default = {};
        };
      };
    }));
    default = {};
  };

  config = {
    home.extraProfileCommands = ''
      source ${makeWrapper}/nix-support/setup-hook
      ${concatMapStringsSep "\n" (p: ''
        wrapProgram ${placeholder "out"}/bin/${p} ${wrapArgs}
      '') ["vi" "vim" "nvim"]}
    '';
    home.packages = [gnvim];
    lib.packages = {inherit gnvim;};

    programs.neovim = {
      inherit plugins extraPackages;
      extraConfig = ''
        ${normalConfig}
      '';
      extraPython3Packages = pythonPackages;
    };
  };
}
