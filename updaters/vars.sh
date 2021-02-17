#!/bin/bash
. vars.conf
output="vars.conf"

echo "# This file is automatically generated (based on this file)

# ~~~~~~~~~~~~~~~~~~~~~~~
# auto-builder.yml
# ~~~~~~~~~~~~~~~~~~~~~~~

TAGS='${TAGS}'
LATEST='${LATEST}'

BUILD_SCHEDULE='${BUILD_SCHEDULE}'
BRANCH='${BRANCH}'
DOCKERHUB_IMAGE='${DOCKERHUB_IMAGE}'
APP_VERSION_LINK='${APP_VERSION_LINK}'
PLATFORMS='${PLATFORMS}'
APP_BRANCH='${APP_BRANCH}'
BASE_OS='${BASE_OS}'
ON_RELEASE='${ON_RELEASE}'
VERSIONING='${VERSIONING}'
BUILD_ARGS='${BUILD_ARGS}'
TEST_SEARCH='${TEST_SEARCH}'
IMAGES='${IMAGES}'" >${output}

echo "
# ~~~~~~~~~~~~~~~~~~~~~~~
# auto-release.yml
# ~~~~~~~~~~~~~~~~~~~~~~~

RELEASE_SCHEDULE='${RELEASE_SCHEDULE}'
BEAUTY_NAME='${BEAUTY_NAME}'
# apostrophe needs be replaced by '\x27'" >>${output}
echo "RELEASE_VERSION_COMMAND='$(echo "${RELEASE_VERSION_COMMAND}" | sed s/"'"/'apos'/g)'" | sed s/'apos'/'\\x27'/g >>${output}
