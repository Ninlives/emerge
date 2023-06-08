{ config, pkgs, echo, ... }:
with pkgs;
let
  inherit (config) ref;
  dp = config.secrets.decrypted;

  system = echo.config.system.build.toplevel;
  netboot = echo.config.nano;

  cat = "${coreutils}/bin/cat";
  touch = "${coreutils}/bin/touch";
  chmod = "${coreutils}/bin/chmod";
  mktemp = "${coreutils}/bin/mktemp";
  printenv = "${coreutils}/bin/printenv";

  rm = "${coreutils}/bin/rm";
  jq = "${pkgs.jq}/bin/jq";
  age = "${pkgs.age}/bin/age";
  nix = "${pkgs.nix}/bin/nix --experimental-features nix-command";
  sed = "${gnused}/bin/sed";
  ssh = "${openssh}/bin/ssh";
  tar = "${gnutar}/bin/tar";
  curl = "${pkgs.curl}/bin/curl";

  createInitSystem = writeShellScript "create" ''
    set -e

    STATE="INIT"
    PATH=${gzip}/bin
    CACHE_DIR=$(${mktemp} -d)
    TEMP_DIR=$(${mktemp} -d)

    function cleanup(){
      ${rm} -rf $CACHE_DIR
      ${rm} -rf $TEMP_DIR
      if [[ "$STATE" == "RELEASE_CREATED" ]];then
        ${curl} -X DELETE \
          -H "Accept: application/vnd.github+json" \
          -H "Authorization: Bearer $GITHUB_TOKEN" "$RELEASE_URL"
      fi
    }
    trap cleanup EXIT

    echo Create release.
    RELEASE_JSON=$(${curl} -X POST \
                        -H "Accept: application/vnd.github+json" \
                        -H "Authorization: Bearer $GITHUB_TOKEN" \
                           "https://api.github.com/repos/Ninlives/emerge/releases" \
                        -d '{"tag_name":"System"}')

    if [[ $? -ne 0 || $(echo "$RELEASE_JSON"|${jq} -r 'has("errors")') == 'true' ]];then
      echo Failed to create release.
      exit 1
    fi

    RELEASE_ID=$(echo "$RELEASE_JSON"|${jq} -r '.["id"]')
    RELEASE_URL=$(echo "$RELEASE_JSON"|${jq} -r '.["url"]')

    STATE="RELEASE_CREATED"

    ${touch} $TEMP_DIR/sign.key
    ${chmod} 600 $TEMP_DIR/sign.key
    ${printenv} SIGN_KEY > $TEMP_DIR/sign.key
    ${nix} store sign --key-file $TEMP_DIR/sign.key -r ${system}
    ${nix} copy --to file://$CACHE_DIR ${system}

    pushd $CACHE_DIR
    ${tar} cvz *|${age} -r $SERVER_PUB -o $TEMP_DIR/system.tar.gz.age
    popd

    echo Upload system tarball.
    TARBALL_JSON=$(${curl} \
                     -H "Accept: application/vnd.github+json" \
                     -H "Authorization: Bearer $GITHUB_TOKEN" \
                     -H "Content-Type: application/octet-stream" \
                        "https://uploads.github.com/repos/Ninlives/emerge/releases/$RELEASE_ID/assets?name=tarball" \
                     --data-binary @$TEMP_DIR/system.tar.gz.age)

    if [[ $? -ne 0 || $(echo "$TARBALL_JSON"|${jq} -r 'has("errors")') == 'true' ]];then
      echo Failed to upload system tarball.
      exit 1
    fi

    ${jq} --null-input \
      --arg id "$RELEASE_ID" \
      --arg system_url "$(echo "$TARBALL_JSON"|${jq} -r '.["browser_download_url"]')" \
      --arg system_path "${system}" \
      --arg release "$RELEASE_URL" \
      '{ "system-path": $system_path , "system-url": $system_url, "release-id": $id , "release-url": $release }'

    STATE="SUCCESS"
  '';

  deleteInitSystem = writeShellScript "delete" ''
    RELEASE_URL=$(${cat}|${jq} -r '.["release-url"]')
    ${curl} -X DELETE \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $GITHUB_TOKEN" "$RELEASE_URL"
  '';

  createNetboot = writeShellScript "create" ''
    set -e

    STATE="INIT"
    PATH=
    CACHE_DIR=$(${mktemp} -d)
    TEMP_DIR=$(${mktemp} -d)

    function cleanup(){
      ${rm} -rf $CACHE_DIR
      ${rm} -rf $TEMP_DIR
      if [[ "$STATE" == "RELEASE_CREATED" ]];then
        ${curl} -X DELETE \
          -H "Accept: application/vnd.github+json" \
          -H "Authorization: Bearer $GITHUB_TOKEN" "$RELEASE_URL"
      fi
    }
    trap cleanup EXIT

    echo Create release.
    RELEASE_JSON=$(${curl} -X POST \
                        -H "Accept: application/vnd.github+json" \
                        -H "Authorization: Bearer $GITHUB_TOKEN" \
                           "https://api.github.com/repos/Ninlives/emerge/releases" \
                        -d '{"tag_name":"iPXE"}')

    if [[ $? -ne 0 || $(echo "$RELEASE_JSON"|${jq} -r 'has("errors")') == 'true' ]];then
      echo Failed to create release.
      exit 1
    fi

    RELEASE_ID=$(echo "$RELEASE_JSON"|${jq} -r '.["id"]')
    RELEASE_URL=$(echo "$RELEASE_JSON"|${jq} -r '.["url"]')

    STATE="RELEASE_CREATED"

    echo Upload initrd.
    INITRD_JSON=$(${curl} \
                    -H "Accept: application/vnd.github+json" \
                    -H "Authorization: Bearer $GITHUB_TOKEN" \
                    -H "Content-Type: application/octet-stream" \
                       "https://uploads.github.com/repos/Ninlives/emerge/releases/$RELEASE_ID/assets?name=initrd" \
                    --data-binary @${netboot}/initrd)

    if [[ $? -ne 0 || $(echo "$INITRD_JSON"|${jq} -r 'has("errors")') == 'true' ]];then
      echo Failed to upload initrd.
      exit 1
    fi

    INITRD_URL=$(echo "$INITRD_JSON"|${jq} -r '.["browser_download_url"]')

    echo Upload bzImage.
    BZIMG_JSON=$(${curl} \
                   -H "Accept: application/vnd.github+json" \
                   -H "Authorization: Bearer $GITHUB_TOKEN" \
                   -H "Content-Type: application/octet-stream" \
                      "https://uploads.github.com/repos/Ninlives/emerge/releases/$RELEASE_ID/assets?name=bzImage" \
                   --data-binary @${netboot}/bzImage)

    if [[ $? -ne 0 || $(echo "$BZIMG_JSON"|${jq} -r 'has("errors")') == 'true' ]];then
      echo Failed to upload initrd.
      exit 1
    fi

    BZIMG_URL=$(echo "$BZIMG_JSON"|${jq} -r '.["browser_download_url"]')

    echo Upload ipxe script.
    ${sed} -e "s|^kernel bzImage|kernel $BZIMG_URL|" \
        -e "s|^initrd initrd|initrd $INITRD_URL|" \
           "${netboot}/ipxe" > $TEMP_DIR/ipxe

    IPXE_JSON=$(${curl} \
                  -H "Accept: application/vnd.github+json" \
                  -H "Authorization: Bearer $GITHUB_TOKEN" \
                  -H "Content-Type: application/octet-stream" \
                     "https://uploads.github.com/repos/Ninlives/emerge/releases/$RELEASE_ID/assets?name=ipxe" \
                  --data-binary @$TEMP_DIR/ipxe)

    if [[ $? -ne 0 || $(echo "$IPXE_JSON"|${jq} -r 'has("errors")') == 'true' ]];then
      echo Failed to upload ipxe script.
      exit 1
    fi

    ${jq} --null-input \
      --arg id "$RELEASE_ID" \
      --arg ipxe "$(echo "$IPXE_JSON"|${jq} -r '.["browser_download_url"]')" \
      --arg release "$RELEASE_URL" \
      '{ "ipxe-url": $ipxe , "release-id": $id , "release-url": $release }'

    STATE="SUCCESS"
  '';

  deleteNetboot = writeShellScript "delete" ''
    RELEASE_URL=$(${cat}|${jq} -r '.["release-url"]')
    ${curl} -X DELETE \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $GITHUB_TOKEN" "$RELEASE_URL"
  '';
in {
  provider.shell = {
    interpreter = [ runtimeShell "-c" ];
    enable_parallelism = true;
  };
  resource.shell_script.netboot = {
    lifecycle_commands = {
      create = "${createNetboot}";
      delete = "${deleteNetboot}";
    };
    sensitive_environment.GITHUB_TOKEN = ref.local.secrets.api-key.github;
  };
  resource.shell_script.init-system = {
    lifecycle_commands = {
      create = "${createInitSystem}";
      delete = "${deleteInitSystem}";
    };
    environment.SERVER_PUB = dp.age.server.pubkey;
    sensitive_environment = {
      GITHUB_TOKEN = ref.local.secrets.api-key.github;
      SIGN_KEY = ref.local.secrets.sign-key;
    };
  };
  resource.shell_script.switch =
    let ip = config.resource.vultr_instance.server "main_ip";
    in {
      lifecycle_commands = {
        create = /* bash */ ''
            set -e
            if [[ "${system}" == "${
              config.resource.shell_script.init-system "output.system-path"
            }" ]];then
              echo Same as init, no need to switch
            else
              echo Copying paths...
              ${nix} copy --to ssh://root@${ip} ${system}
              echo Transferring secrets...
              printenv B2_ENV|${ssh} root@${ip} 'cat > /chest/Static/b2/env'
              echo Switching...
              ${ssh} root@${ip} \
                'nix-env -p /nix/var/nix/profiles/system --set ${system} \
                && ${system}/bin/switch-to-configuration boot \
                && reboot'
            fi
            echo '{ "path": "${system}" }'
          '';
        delete = /* bash */ "echo No-op for switch";
      };
      sensitive_environment = {
        B2_ENV = ''
          B2_ACCOUNT_ID='${config.resource.b2_application_key.chest "application_key_id"}'
          B2_ACCOUNT_KEY='${config.resource.b2_application_key.chest "application_key"}'
        '';
      };
      triggers.when_value_changed = "${system}";
    };
}
