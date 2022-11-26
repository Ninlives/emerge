#!/usr/bin/env bash
set -e

SYSTEM_PATH=$(nix build emerge#nixosConfigurations.echo.config.system.build.toplevel --no-link --print-out-paths)

CACHE_DIR=$(mktemp -d)
TEMP_DIR=$(mktemp -d)

function cleanup(){
  rm -rf ${CACHE_DIR}
  rm -rf ${TEMP_DIR}
}
trap cleanup EXIT

echo Create release.
RELEASE_JSON=$(curl -X POST \
                    -H "Accept: application/vnd.github+json" \
                    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                       "https://api.github.com/repos/Ninlives/emerge/releases" \
                    -d '{"tag_name":"System"}')

if [[ $(echo "${RELEASE_JSON}"|jq -r 'has("errors")') == 'true' ]];then
  echo Failed to create release.
  exit 1
fi

RELEASE_ID=$(echo "${RELEASE_JSON}"|jq -r '.["id"]')

touch ${TEMP_DIR}/sign.key
chmod 600 ${TEMP_DIR}/sign.key
printenv SIGN_KEY > ${TEMP_DIR}/sign.key
nix store sign --key-file ${TEMP_DIR}/sign.key -r ${SYSTEM_PATH}
nix copy --to file://${CACHE_DIR} ${SYSTEM_PATH}

pushd ${CACHE_DIR}
tar cvz *|age -r ${SERVER_PUB} -o ${TEMP_DIR}/system.tar.gz.age
popd

echo Upload system tarball.
TARBALL_JSON=$(curl \
                 -H "Accept: application/vnd.github+json" \
                 -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                 -H "Content-Type: application/octet-stream" \
                    "https://uploads.github.com/repos/Ninlives/emerge/releases/${RELEASE_ID}/assets?name=tarball" \
                 --data-binary @${TEMP_DIR}/system.tar.gz.age)

if [[ $(echo "${TARBALL_JSON}"|jq -r 'has("errors")') == 'true' ]];then
  echo Failed to upload system tarball.
  exit 1
fi

jq --null-input \
  --arg id "${RELEASE_ID}" \
  --arg system_url "$(echo "${TARBALL_JSON}"|jq -r '.["browser_download_url"]')" \
  --arg system_path "${SYSTEM_PATH}" \
  --arg release "$(echo "${RELEASE_JSON}"|jq -r '.["url"]')" \
  '{ "system-path": $system_path , "system-url": $system_url, "release-id": $id , "release-url": $release }'
