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

      - name: Create Version
        env:
          TOKEN: ${{ secrets.TOKEN }}
        run: |
          git config --global user.email "github-actions@github.com"
          git config --global user.name "github-actions"' >${output}
	echo -e '          VERSION='"${RELEASE_VERSION_COMMAND}"'' >>${output}
	echo -e '          OLD_VERSION=$(curl -sL "https://api.github.com/repos/hydazz/docker-'"${DOCKERHUB_IMAGE}"'/releases/latest" | jq -r \x27.tag_name\x27)' >>${output}
	echo "          printf '{
               \"tag_name\": \"'\${VERSION}'\",
               \"target_commitish\": \"'\${main}'\",
               \"name\": \"'\${VERSION}'\"," >>${output}
	if [ -n "${CHANGELOG_URL}" ]; then
		echo "               \"body\": \"Upgrading "${BEAUTY_NAME}" '\${OLD_VERSION}' to '\${VERSION}' \n[Changelog](${CHANGELOG_URL})\"," >>${output}
	else
		echo "               \"body\": \"Upgrading "${BEAUTY_NAME}" '\${OLD_VERSION}' to '\${VERSION}'\"," >>${output}
	fi
	echo "               \"draft\": false,
               \"prerelease\": false
          }' >releasebody.json
          curl -H \"Authorization: token \${TOKEN}\" -X POST https://api.github.com/repos/hydazz/docker-${DOCKERHUB_IMAGE}/releases -d @releasebody.json
" >>${output}
else
	[[ -f ${output} ]] &&
		rm ${output}
fi
