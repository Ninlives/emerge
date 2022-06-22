{ var, inputs, ... }:
final: prev: {
  inherit (inputs.external.legacyPackages.${var.system}) re-export;
}
