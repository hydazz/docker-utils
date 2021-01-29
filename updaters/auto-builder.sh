#!/bin/bash

. vars.conf
output="workflows/auto-builder.yml"

[[ -z ${APP_VERSION_LINK} ]] &&
	APP_VERSION_LINK='$(curl -sX GET "https://api.github.com/repos/hydazz/docker-'${DOCKERHUB_IMAGE}'/releases/latest" | jq -r .tag_name)'

# setup
echo '# This file is automatically generated

name: Auto Builder CI

on:
  workflow_dispatch:
  repository_dispatch:' >${output}
[[ -n ${BUILD_SCHEDULE} ]] &&
	echo '  schedule:
    - cron: "'"${BUILD_SCHEDULE}"'"' >>${output}
[[ ${ON_RELEASE} == "true" ]] &&
	echo '  release:
    types:
      - released' >>${output}
echo '
jobs:' >>${output}
for tag in ${TAGS}; do
	echo '  '"${BASE_OS}"'-'"${tag/./-}"':
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        with:
          ref: '"${BRANCH}"'
          fetch-depth: 0

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v1

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1
        id: buildx

      - name: Docker Login
        uses: docker/login-action@v1
        with:
          username: vcxpz
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Github Login
        run: |
          git config --global user.email "github-actions@github.com"
          git config --global user.name "github-actions"' >>${output}
	if [[ -n ${TEST_SEARCH} ]]; then
		echo '
      - name: Build The Docker Image For Testing
        run: |
          docker build \' >>${output}
		[[ ${VERSIONING} == "true" ]] &&
			echo '            --build-arg VERSION='"${APP_VERSION_LINK}"' \' >>${output}
		if [[ -n ${BUILD_ARGS} ]]; then
			echo "${BUILD_ARGS}" | while read -r i; do
				echo '            '"${i}"' \' >>${output}
			done
		fi
		[[ -n ${APP_BRANCH} ]] &&
			echo '            --build-arg BRANCH="'"${APP_BRANCH}"'" \' >>${output}
		echo '            --tag vcxpz/ci-build:ci-build \
            --build-arg TAG='"${tag}"' \
            --file Dockerfile .

      - name: Test The Docker Image
        run: |
          export IMAGE="vcxpz/ci-build:ci-build"
          export TEST_SEARCH="'"${TEST_SEARCH}"'"
          export RUN_ARGS="-e DEBUG=true"
          curl -sSL https://raw.githubusercontent.com/hydazz/docker-utils/main/docker/docker-ci.sh | bash' >>${output}
	fi
	echo '
      - name: Build And Push The Docker Image
        run: |
          docker buildx build \
            --platform='"${PLATFORMS}"' \
            --output "type=image,push=true" \
            --build-arg TAG='"${tag}"' \
            --build-arg BUILD_DATE="$(date +%Y-%m-%d)" \' >>${output}
	[[ ${VERSIONING} == "true" ]] &&
		echo '            --build-arg VERSION='"${APP_VERSION_LINK}"' \' >>${output}
	if [[ -n ${BUILD_ARGS} ]]; then
		echo "${BUILD_ARGS}" | while read -r i; do
			echo '            '"${i}"' \' >>${output}
		done
	fi
	[[ -n ${APP_BRANCH} ]] &&
		echo '            --build-arg BRANCH="'"${APP_BRANCH}"'" \' >>${output}

	if [ "${LATEST}" == "${tag}" ]; then
		echo '            --tag vcxpz/'"${DOCKERHUB_IMAGE}"':latest \' >>${output}
		[[ ${VERSIONING} == "true" ]] &&
			echo '            --tag vcxpz/'"${DOCKERHUB_IMAGE}"':'"${APP_VERSION_LINK}"' \' >>${output}
	else
		[[ ${VERSIONING} == "true" ]] &&
			echo '            --tag vcxpz/'"${DOCKERHUB_IMAGE}"':'"${tag}"'-'"${APP_VERSION_LINK}"' \' >>${output}
	fi
	echo '            --tag vcxpz/'"${DOCKERHUB_IMAGE}"':'"${tag}"' \
            --file Dockerfile .' >>${output}

	if [[ ${LATEST} == "${tag}" ]]; then
		echo '
      - name: Get New Package Versions From Image
        run: |' >>${output}
		if [[ -n ${TEST_SEARCH} ]]; then
			echo '          docker run --rm --entrypoint /bin/sh -v ${PWD}:/tmp vcxpz/ci-build:ci-build -c '\''\' >>${output}
		else
			echo '          docker run --rm --entrypoint /bin/sh -v ${PWD}:/tmp vcxpz/'"${DOCKERHUB_IMAGE}"':latest -c '\''\' >>${output}
		fi

		[[ ${BASE_OS} == "alpine" ]] &&
			echo '            apk info -v | sort >/tmp/package_versions.txt'\''' >>${output}

		[[ ${BASE_OS} == "ubuntu" ]] &&
			echo '            apt list -qq --installed | sed "s#/.*now ##g" | cut -d" " -f1 | sort >/tmp/package_versions.txt'\''' >>${output}

		[[ -f update_readme.sh ]] &&
			echo '
      - name: Update README
        run: |
          export APP_VERSION='"${APP_VERSION_LINK}"'
          chmod +x .github/update_readme.sh && .github/update_readme.sh' >>${output}
		echo '
      - name: Commit And Push Changes To Github
        run: |
          git add -A
          git commit -m "Bot Updating Files" || echo "No Changes"
          git push || echo "No Changes"

      - name: Sync README With Docker Hub
        uses: peter-evans/dockerhub-description@v2
        with:
          username: vcxpz
          password: ${{ secrets.DOCKER_PASSWORD }}
          repository: '"vcxpz/${DOCKERHUB_IMAGE}"'' >>${output}
		[[ -n ${IMAGES} ]] &&
			echo '
      - name: Trigger Images
        env:
          TOKEN: ${{ secrets.TOKEN }}
        run: |
          curl -sSL https://raw.githubusercontent.com/hydazz/docker-utils/main/github/trigger_build.sh | bash' >>${output}
	fi
	echo "" >>${output}
done
