{ ... }:
final: prev: {
  gnomeExtensions = prev.gnomeExtensions // {
    pixel-saver = prev.gnomeExtensions.pixel-saver.overrideAttrs (p: {
      postUnpack = p.postUnpack or "" + ''
        ${final.jq}/bin/jq -e '.["shell-version"] += ["44"]' < pixel-saver@deadalnix.me/metadata.json | \
        ${final.moreutils}/bin/sponge pixel-saver@deadalnix.me/metadata.json
      '';
    });
  };
}
