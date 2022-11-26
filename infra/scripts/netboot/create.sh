#!/usr/bin/env bash
set -e

NETBOOT_PATH=$(nix build emerge#nixosConfigurations.echo.config.nano --no-link --print-out-paths)

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
                    -d '{"tag_name":"iPXE"}')

if [[ $(echo "${RELEASE_JSON}"|jq -r 'has("errors")') == 'true' ]];then
  echo Failed to create release.
  exit 1
fi

RELEASE_ID=$(echo "${RELEASE_JSON}"|jq -r '.["id"]')

echo Upload initrd.
INITRD_JSON=$(curl \
                -H "Accept: application/vnd.github+json" \
                -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                -H "Content-Type: application/octet-stream" \
                   "https://uploads.github.com/repos/Ninlives/emerge/releases/${RELEASE_ID}/assets?name=initrd" \
                --data-binary @${NETBOOT_PATH}/initrd)

if [[ $(echo "${INITRD_JSON}"|jq -r 'has("errors")') == 'true' ]];then
  echo Failed to upload initrd.
  exit 1
fi

INITRD_URL=$(echo "${INITRD_JSON}"|jq -r '.["browser_download_url"]')

echo Upload bzImage.
BZIMG_JSON=$(curl \
               -H "Accept: application/vnd.github+json" \
               -H "Authorization: Bearer ${GITHUB_TOKEN}" \
               -H "Content-Type: application/octet-stream" \
                  "https://uploads.github.com/repos/Ninlives/emerge/releases/${RELEASE_ID}/assets?name=bzImage" \
               --data-binary @${NETBOOT_PATH}/bzImage)

if [[ $(echo "${BZIMG_JSON}"|jq -r 'has("errors")') == 'true' ]];then
  echo Failed to upload initrd.
  exit 1
fi

BZIMG_URL=$(echo "${BZIMG_JSON}"|jq -r '.["browser_download_url"]')

echo Upload ipxe script.
sed -e "s|^kernel bzImage|kernel ${BZIMG_URL}|" \
    -e "s|^initrd initrd|initrd ${INITRD_URL}|" \
       "${NETBOOT_PATH}/ipxe" > ${TEMP_DIR}/ipxe

IPXE_JSON=$(curl \
              -H "Accept: application/vnd.github+json" \
              -H "Authorization: Bearer ${GITHUB_TOKEN}" \
              -H "Content-Type: application/octet-stream" \
                 "https://uploads.github.com/repos/Ninlives/emerge/releases/${RELEASE_ID}/assets?name=ipxe" \
              --data-binary @${TEMP_DIR}/ipxe)

if [[ $(echo "${IPXE_JSON}"|jq -r 'has("errors")') == 'true' ]];then
  echo Failed to upload ipxe script.
  exit 1
fi

jq --null-input \
  --arg id "${RELEASE_ID}" \
  --arg ipxe "$(echo "${IPXE_JSON}"|jq -r '.["browser_download_url"]')" \
  --arg release "$(echo "${RELEASE_JSON}"|jq -r '.["url"]')" \
  '{ "ipxe-url": $ipxe , "release-id": $id , "release-url": $release }'
