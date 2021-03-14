#!/bin/bash
# watches docker logs for '${TEST_SEARCH}' which usally means container booted successfully
# this script is not really useful as if a service fails to start it will not know

TIMEOUT=$((SECONDS + 30)) # time in seconds to wait for '${TEST_SEARCH}' in logs (timeout)

docker run -d --name=ci-test -e DEBUG=true vcxpz/ci-build:ci-build >/dev/null
while [[ "$SECONDS" -lt "$TIMEOUT" ]]; do
	if docker logs ci-test 2>&1 | grep -q "${TEST_SEARCH}"; then
		FAILED=false
		break
	fi
	sleep 1
done

docker stop ci-test >/dev/null

if [[ "$FAILED" == "false" ]]; then
	echo "✅ Test Succeeded"
	docker logs ci-test
	docker rm ci-test >/dev/null
	exit 0
else
	echo "❌ Test Failed"
	docker logs ci-test
	docker rm ci-test >/dev/null
	exit 1
fi
