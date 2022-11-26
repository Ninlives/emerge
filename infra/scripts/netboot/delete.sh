#!/usr/bin/env bash

RELEASE_URL=$(cat|jq -r '.["release-url"]')

curl -X DELETE \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
     "${RELEASE_URL}"
