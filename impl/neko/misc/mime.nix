{ lib, ... }:
with lib;
let
  web-mimes = [
    "x-scheme-handler/http"
    "text/html"
    "application/xhtml+xml"
    "x-scheme-handler/https"
  ];
  image-mimes = [
    "image/jpeg"
    "image/bmp"
    "image/gif"
    "image/jpg"
    "image/pjpeg"
    "image/png"
    "image/tiff"
    "image/webp"
    "image/x-bmp"
    "image/x-gray"
    "image/x-icb"
    "image/x-ico"
    "image/x-png"
    "image/x-portable-anymap"
    "image/x-portable-bitmap"
    "image/x-portable-graymap"
    "image/x-portable-pixmap"
    "image/x-xbitmap"
    "image/x-xpixmap"
    "image/x-pcx"
    "image/svg+xml"
    "image/svg+xml-compressed"
    "image/vnd.wap.wbmp"
    "image/x-icns"
  ];
  mkAssoc = mimes: app:
    listToAttrs (map (mime: {
      name = mime;
      value = app;
    }) mimes);
  assoc = (mkAssoc web-mimes "org.qutebrowser.qutebrowser.desktop")
    // (mkAssoc image-mimes "org.gnome.eog.desktop");
in {
  xdg.mimeApps.associations.removed."application/pdf" = "draw.desktop";
  xdg.mimeApps.associations.added = {
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
      "impress.desktop";
    "application/msword" = "writer.desktop";
  } // assoc;
  xdg.mimeApps.defaultApplications = assoc;
}
