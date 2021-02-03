#!/bin/bash
# watches docker logs for '${TEST_SEARCH}' which usally means container booted successfully
# this script is not really useful as if a service fails to start it will not know

TIMEOUT=$((SECONDS + 120)) # time in seconds to wait for '${TEST_SEARCH}' in logs (timeout)

docker run -d --name=logger -e DEBUG=true vcxpz/ci-build:ci-build >/dev/null
while [[ "$SECONDS" -lt "$TIMEOUT" ]]; do
	if docker logs logger 2>&1 | grep -q "${TEST_SEARCH}"; then
		FAILED=false
		break
	fi
	sleep 1
done
sleep 5
docker stop logger >/dev/null
docker rm logger >/dev/null

if [[ "$FAILED" == "false" ]]; then
	echo "✅ Test Succeeded"
	exit 0
else
	echo "❌ Test Failed"
	docker logs logger
	exit 1
fi
