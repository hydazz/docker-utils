#!/bin/bash
exit 1
# watches docker logs for '${TEST_SEARCH}' which usally means container booted successfully
# this script is not really useful as if a service fails to start it will not know

TIMEOUT=$((SECONDS + 120)) # time in seconds to wait for '${TEST_SEARCH}' in logs (timeout)
docker run -d --name=logger ${RUN_ARGS} ${CONT_ARGS} "${IMAGE}" >/dev/null
while [[ "$SECONDS" -lt "$TIMEOUT" ]]; do
	if docker logs logger 2>&1 | grep -q "${TEST_SEARCH}"; then
		FAILED=false
		break
	fi
	sleep 1
done
sleep 5
docker stop logger >/dev/null
docker logs logger
docker rm logger >/dev/null
if [[ "$FAILED" == "false" ]]; then
	exit 0
else
	exit 1
fi
