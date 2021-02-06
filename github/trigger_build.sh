#!/bin/bash

. .github/vars.conf

for i in ${IMAGES}; do
	echo "Triggering build for ${i}"
	curl \
		-H "Accept: application/vnd.github.everest-preview+json" \
		-H "Authorization: token ${TOKEN}" \
		--request POST \
		--data '{"event_type": "Auto Trigger"}' \
		https://api.github.com/repos/hydazz/docker-${i}/dispatches
done
