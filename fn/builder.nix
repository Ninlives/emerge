{
  mkApp = {
    drv,
    name ? drv.pname or drv.name,
    exePath ? drv.exePath or "/bin/${name}",
  }: {
    type = "app";
    program = "${drv}${exePath}";
  };
}
