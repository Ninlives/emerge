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
      "sha256:25ef6cc97deaa76ef760e131792d66064b4d270eb3a2bae83533d22153a0831f";
    sha256 = "045f1h9y7prhmnjs6w0s4y21wdsqj6af6fz2i413x1d28yragywl";
    finalImageName = "altran1502/immich-server";
    finalImageTag = "release";
  };
  immich-machine-learning-image = pullImage {
    imageName = "altran1502/immich-machine-learning";
    imageDigest =
      "sha256:e40e43ccdf43bc42f0ade9edf9b6e3562fd589e756042010f86631cd28b1172b";
    sha256 = "1phvcl6l4hs3pa7wqy19yd0wjk2ji92i5arzsxy5wfpal1s00ibq";
    finalImageName = "altran1502/immich-machine-learning";
    finalImageTag = "release";
  };
  immich-web-image = pullImage {
    imageName = "altran1502/immich-web";
    imageDigest =
      "sha256:aa00f584d039962f9a2d452f9040922909410edf1e1b36f09bc476bd32aa7595";
    sha256 = "1n63in6g9wxin0530bqkjp0irxmlm2jqka8w4czx7gs38v3428xb";
    finalImageName = "altran1502/immich-web";
    finalImageTag = "release";
  };
  immich-proxy-image = pullImage {
    imageName = "altran1502/immich-proxy";
    imageDigest =
      "sha256:4a62907a5e514cef8a8a0f5bf9b5dc4dd941e9a5493648259ac855bd5bf219fa";
    sha256 = "1qszhvi5vwdz6yqkw45x6bl6cw8yrcbiniyv7y7aakr8x2abcc13";
    finalImageName = "altran1502/immich-proxy";
    finalImageTag = "release";
  };
  redis-image = pullImage {
    imageName = "redis";
    imageDigest =
      "sha256:ffd3d04c8f7832ccdda89616ebaf3cb38414b645ebbf76dbef1fc9c36a72a2d1";
    sha256 = "1p7ckhb6hfppzj0hqskb0fni1ia02zc9cbnh87kih7aqyqdjabx8";
    finalImageName = "redis";
    finalImageTag = "6.2";
  };
  database-image = pullImage {
    imageName = "postgres";
    imageDigest =
      "sha256:135c62a8134dcef829a1e4f5568bfae44bcfa2c75659ff948f43c71964366aa4";
    sha256 = "07wp7cbazmzd71ap5v5b945j97cgpz1jdj6q33wa2b7cv3hmy151";
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
