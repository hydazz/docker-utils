#!/bin/bash

. vars.conf
output="workflows/auto-release.yml"

if [[ -n ${RELEASE_VERSION_COMMAND} ]]; then
	echo '# This file is automatically generated

name: Auto Release CI

on:
  workflow_dispatch:
  schedule:
    - cron: "'"${RELEASE_SCHEDULE}"'"

jobs:
  check-for-updates:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Create Tag
        env:
          TOKEN: ${{ secrets.TOKEN }}
        run: |
          git config --global user.email "github-actions@github.com"
          git config --global user.name "github-actions"' >${output}
	echo -e '          VERSION='${RELEASE_VERSION_COMMAND}'' >>${output}
	echo '          OLD_VERSION=$(curl -sX GET "https://api.github.com/repos/hydazz/docker-'${DOCKERHUB_IMAGE}'/releases/latest" | jq -r .tag_name)' >>${output}
	echo "          printf '{
               \"tag_name\": \"'\${VERSION}'\",
               \"target_commitish\": \"'\${main}'\",
               \"name\": \"'\${VERSION}'\",
               \"body\": \"Upgrading Sonarr '\${OLD_VERSION}' to '\${VERSION}'\",
               \"draft\": false,
               \"prerelease\": false
          }' >releasebody.json
          curl -H \"Authorization: token \${TOKEN}\" -X POST https://api.github.com/repos/hydazz/docker-${DOCKERHUB_IMAGE}/releases -d @releasebody.json
" >>${output}
fi
