#!/bin/bash
ARCH=$(arch)

# x64
[[ "$ARCH" == "x86_64" ]] &&
	ARCH="amd64"

# arm32
[[ "$ARCH" == "armv7"* ]] &&
	ARCH="armhf"

# arm64
[[ "$ARCH" == "aarch64" ]] &&
	ARCH="arm64"

echo ${ARCH}