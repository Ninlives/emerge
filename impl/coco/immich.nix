{ pkgs, config, inputs, ... }:
let
  inherit (config.lib.path) persistent;
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  dp = inputs.values.secret;

  upload-box = "${persistent.data}/immich/upload";
  database-box = "${persistent.data}/immich/database";

  inherit (pkgs.dockerTools) pullImage;
  immich-server-image = pullImage {
    imageName = "ghcr.io/immich-app/immich-server";
    imageDigest = "sha256:54fdba947976dd64c47b51b50905a76c5ecea950b24163f146e57459b846d3c2";
    sha256 = "0wl5936pn4l7v30g34x7l7fcvqr74p6ylgd6s99j1zq0blbk04zr";
    finalImageName = "ghcr.io/immich-app/immich-server";
    finalImageTag = "release";
  };
  immich-web-image = pullImage {
    imageName = "ghcr.io/immich-app/immich-web";
    imageDigest = "sha256:381ef4e192e9a8caeb76862ad46ce15965cc35add2e729243e5cbe9d106c2c12";
    sha256 = "1lpp57jbg1i8z7rcf9gqskrn0m6zvj0159y4y0l4mjwxsjk5iggj";
    finalImageName = "ghcr.io/immich-app/immich-web";
    finalImageTag = "release";
  };
  immich-proxy-image = pullImage {
    imageName = "ghcr.io/immich-app/immich-proxy";
    imageDigest = "sha256:efaa57f3fdee0aa27d96eb944d75ddf93160dc82c657d49c825addd484fdc3d6";
    sha256 = "11q1n3fnmx6c95xz96gbl6hg00rvykwz5m4dywxpavv8i1k720pj";
    finalImageName = "ghcr.io/immich-app/immich-proxy";
    finalImageTag = "release";
  };
  redis-image = pullImage {
    imageName = "redis";
    imageDigest = "sha256:423276a3cea98336607ec04db7cf69ed2b7a27d8d306ec37074956f058da79bc";
    sha256 = "0bm362kzr59lriplb52mqgv4kgcs9gv0zwvxixarja5p2viylzab";
    finalImageName = "redis";
    finalImageTag = "6.2";
  };
  database-image = pullImage {
    imageName = "postgres";
    imageDigest = "sha256:18050649e69395b9b76e38af69055b0e522c307c2fc5951c5289324832876aae";
    sha256 = "00fm7wj1mjg5zx1lmy5s9mzhy9cqp6caq4hcjasaq5bdlqh3db94";
    finalImageName = "postgres";
    finalImageTag = "14";
  };
in {
  sops.templates.immich-env.content = ''
    NODE_ENV=production
    DB_HOSTNAME=immich-database
    DB_DATABASE_NAME=immich
    DB_USERNAME=${plh."immich/postgres/username"}
    DB_PASSWORD=${plh."immich/postgres/password"}
    REDIS_HOSTNAME=immich-redis
    UPLOAD_LOCATION=${upload-box}
    LOG_LEVEL=verbose
    JWT_SECRET=${plh."immich/jwt"}
    PUBLIC_LOGIN_PAGE_MESSAGE=Cheers!

    POSTGRES_DB=immich
    POSTGRES_USER=${plh."immich/postgres/username"}
    POSTGRES_PASSWORD=${plh."immich/postgres/password"}
    PG_DATA=/var/lib/postgresql/data

    # TODO
    IMMICH_MACHINE_LEARNING_URL=false
    TYPESENSE_ENABLED=false
  '';

  virtualisation.oci-containers.backend = "podman";
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
  virtualisation.podman.enableNvidia = true;
  networking.firewall.trustedInterfaces = [ "podman0" ];
  virtualisation.oci-containers.containers = {
    immich-server = {
      image = "ghcr.io/immich-app/immich-server:release";
      imageFile = immich-server-image;
      entrypoint = "/bin/sh";
      cmd = [ "./start-server.sh" ];
      volumes = [ "${upload-box}:/usr/src/app/upload" ];
      environmentFiles = [ tpl.immich-env.path ];
      dependsOn = [ "immich-redis" "immich-database" ];
    };

    immich-microservice = {
      image = "ghcr.io/immich-app/immich-server:release";
      imageFile = immich-server-image;
      entrypoint = "/bin/sh";
      cmd = [ "./start-microservices.sh" ];
      volumes = [ "${upload-box}:/usr/src/app/upload" ];
      environmentFiles = [ tpl.immich-env.path ];
      dependsOn = [ "immich-redis" "immich-database" ];
    };

    # immich-machine-learning = {
    #   image = "altran1502/immich-machine-learning:release";
    #   imageFile = immich-machine-learning-image;
    #   entrypoint = "/bin/sh";
    #   cmd = [ "./entrypoint.sh" ];
    #   volumes = [ "${upload-box}:/usr/src/app/upload" ];
    #   environmentFiles = [ tpl.immich-env.path ];
    #   dependsOn = [ "immich-database" ];
    # };

    immich-web = {
      image = "ghcr.io/immich-app/immich-web:release";
      imageFile = immich-web-image;
      entrypoint = "/bin/sh";
      cmd = [ "./entrypoint.sh" ];
      environmentFiles = [ tpl.immich-env.path ];
    };

    immich-redis = {
      image = "redis:6.2";
      imageFile = redis-image;
    };

    immich-database = {
      image = "postgres:14";
      imageFile = database-image;
      environmentFiles = [ tpl.immich-env.path ];
      volumes = [ "${database-box}:/var/lib/postgresql/data" ];
    };

    immich-proxy = {
      image = "ghcr.io/immich-app/immich-proxy:release";
      imageFile = immich-proxy-image;
      ports = [ "127.0.0.1:${toString dp.host.private.services.immich.port}:8080" ];
      dependsOn = [ "immich-server" ];
    };
  };

  revive.specifications.system.boxes =
    [ { dst = upload-box; } { dst = database-box; } ];
}
