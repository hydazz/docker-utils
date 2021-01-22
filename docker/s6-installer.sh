#!/bin/bash
OVERLAY_ARCH=$(arch)

if [[ -z "${OVERLAY_VERSION}" ]]; then
	echo "no overlay version specified"
	exit 1
fi

# amd64
[[ "$OVERLAY_ARCH" == "x86_64" ]] &&
	OVERLAY_ARCH="amd64"

# arm
[[ "$OVERLAY_ARCH" == "arm"* ]] &&
	OVERLAY_ARCH="arm"

if [[ $OVERLAY_ARCH == "s390x" ]]; then
	echo "s6 overlay does not have s390x"
	exit 1
fi

function download() {
	url="https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}-installer"
	filename="s6-overlay-${OVERLAY_ARCH}-installer"

	if command -v wget &>/dev/null; then
		wget -q "$url" -O $filename
	elif command -v curl &>/dev/null; then
		curl -o $filename -sfL "$url"
	else
		echo "Could not find curl or wget, please install one."
		exit 1
	fi
}

download
chmod +x s6-overlay-${OVERLAY_ARCH}-installer
./s6-overlay-${OVERLAY_ARCH}-installer "/" >/dev/null # don't spam the docker logs
rm s6-overlay-${OVERLAY_ARCH}-installer
