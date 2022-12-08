{ pkgs, config, var, ... }:
let
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  dp = config.secrets.decrypted;
  net = var.net.default;
  scrt = config.sops.secrets;

  upload-box = "/chest/Data/immich/upload";
  database-box = "/chest/Data/immich/database";

  inherit (pkgs.dockerTools) pullImage;
  immich-server-image = pullImage {
    imageName = "altran1502/immich-server";
    imageDigest =
      "sha256:69b8f2b3add2b42e853938f871d4b744adc9391ab8d121462b7e3d670fe2eaa6";
    sha256 = "0ivn0g973h119ilfsf06r8yrdh21mg0b9x354m8pdv32j95zkz58";
    finalImageName = "altran1502/immich-server";
    finalImageTag = "release";
  };
  immich-machine-learning-image = pullImage {
    imageName = "altran1502/immich-machine-learning";
    imageDigest =
      "sha256:37d8bbe15bbc4fc010ed7a968d355e8e2bc398c39c7dfe80f8ff29689f442b76";
    sha256 = "0dmfk0vs6iglk1j86325ap58fp415q2a7dgldwdr1wr24jp5lnf4";
    finalImageName = "altran1502/immich-machine-learning";
    finalImageTag = "release";
  };
  immich-web-image = pullImage {
    imageName = "altran1502/immich-web";
    imageDigest =
      "sha256:a09d6b8141061717935122fd246b7922ef1ba16ca1166ecadd6db97293f9c57c";
    sha256 = "19n4ks4fnl7k3rldc2hm9zci1w5bmxz4x4xlci5mvdsh394zkrny";
    finalImageName = "altran1502/immich-web";
    finalImageTag = "release";
  };
  immich-proxy-image = pullImage {
    imageName = "altran1502/immich-proxy";
    imageDigest =
      "sha256:508681901ad29476e7247a4d20f24775ead441a600def463da3f39f7c687d443";
    sha256 = "1mbc3hj2i62bj1i3nqlh6bnig51mgcda1avqdhnfm4c0516s0mbr";
    finalImageName = "altran1502/immich-proxy";
    finalImageTag = "release";
  };
  redis-image = pullImage {
    imageName = "redis";
    imageDigest =
      "sha256:a93c14584715ec5bd9d2648d58c3b27f89416242bee0bc9e5fb2edc1a4cbec1d";
    sha256 = "0dny2vk6la7y2h7dpamxyv9zwkkkkc9ha3k4xra2q1djn9634ign";
    finalImageName = "redis";
    finalImageTag = "6.2";
  };
  database-image = pullImage {
    imageName = "postgres";
    imageDigest =
      "sha256:18050649e69395b9b76e38af69055b0e522c307c2fc5951c5289324832876aae";
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
  '';

  virtualisation.oci-containers.backend = "podman";
  virtualisation.podman.defaultNetwork.dnsname.enable = true;
  virtualisation.oci-containers.containers = {
    immich-server = {
      image = "altran1502/immich-server:release";
      imageFile = immich-server-image;
      entrypoint = "/bin/sh";
      cmd = [ "./start-server.sh" ];
      volumes = [ "${upload-box}:/usr/src/app/upload" ];
      environmentFiles = [ tpl.immich-env.path ];
      dependsOn = [ "immich-redis" "immich-database" ];
    };

    immich-microservice = {
      image = "altran1502/immich-server:release";
      imageFile = immich-server-image;
      entrypoint = "/bin/sh";
      cmd = [ "./start-microservices.sh" ];
      volumes = [ "${upload-box}:/usr/src/app/upload" ];
      environmentFiles = [ tpl.immich-env.path ];
      dependsOn = [ "immich-redis" "immich-database" ];
    };

    immich-machine-learning = {
      image = "altran1502/immich-machine-learning:release";
      imageFile = immich-machine-learning-image;
      entrypoint = "/bin/sh";
      cmd = [ "./entrypoint.sh" ];
      volumes = [ "${upload-box}:/usr/src/app/upload" ];
      environmentFiles = [ tpl.immich-env.path ];
      dependsOn = [ "immich-database" ];
    };

    immich-web = {
      image = "altran1502/immich-web:release";
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
      image = "altran1502/immich-proxy:release";
      imageFile = immich-proxy-image;
      ports = [ "127.0.0.1:${toString dp.immich.port}:8080" ];
      dependsOn = [ "immich-server" ];
    };
  };

  revive.specifications.system.boxes =
    [ { dst = upload-box; } { dst = database-box; } ];
}
