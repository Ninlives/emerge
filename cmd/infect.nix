{
  fn,
  self,
  ...
}: {
  perSystem = {pkgs, ...}: let
        nix = "${pkgs.nix}/bin/nix";
  in {
    apps.infect = fn.mkApp {
      drv =
        with pkgs;
          writeShellScriptBin "infect" ''
            gen=$(\
              ${nix} build --no-link --print-out-paths \
                $(${nix} eval --raw '${self}#pathogen.ipomoea' \
                              --apply 'f: (f "'$USER'" "'$HOME'").activationPackage.drvPath')^out\
            )
            HOME_MANAGER_BACKUP_EXT=overridden_by_hm $gen/activate
          '';
    };
    apps.plant =
      fn.mkApp {
        drv = with pkgs; writers.writePython3Bin "plant" {} /* python */ ''
          import os
          import json
          import pathlib
          import argparse

          parser = argparse.ArgumentParser(prog="plant")
          parser.add_argument("action", nargs='+')
          parser.add_argument("-u", "--user")
          parser.add_argument("-d", "--device")
          parser.add_argument("-t", "--fs-type")
          parser.add_argument("-e", "--entry")
          args = {k: v for k, v in vars(parser.parse_args()).items() if v is not None}
          host = args["action"][0]
          command = args["action"][1:]
          del args["action"]

          json_dir = pathlib.Path("~/.local/state/nix/cmd/plant").expanduser()
          json_dir.mkdir(parents=True, exist_ok=True)
          records_json = json_dir / "records.json"

          records = {}
          if records_json.is_file():
              with records_json.open() as f:
                  records = json.load(f)

          record = records.get(host, {})
          record.update(args)
          records[host] = record
          with records_json.open(mode='w') as f:
              json.dump(records, f)


          def check_store_path(path):
              if len(path) <= ${with builtins;toString (stringLength storeDir + 33) }:
                  raise RuntimeError(f"{path} is not a store path")
              return path


          fn = f"""
            f: (f {{
              fs.device = "{record["device"]}";
              fs.type = "{record["fs_type"]}";
              fs.entry = "{record["entry"]}";
              target.user = "{record["user"]}";
              target.host = "{host}";
            }}).config.system.build.plant.drvPath
          """
          drv_cmd = f"${nix} eval --raw '${self}#pathogen.physeter' --apply '{fn}'"  # noqa: E501
          print(drv_cmd)
          drv = check_store_path(os.popen(drv_cmd).read().strip())
          plant = check_store_path(os.popen(f"${nix} build --no-link --print-out-paths {drv}^out").read().strip())  # noqa: E501

          os.execv(plant, [plant] + command)
        '';
      };
  };
}
