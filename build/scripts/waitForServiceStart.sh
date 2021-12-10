#!/bin/bash -x

SERVICE_PORT="$1"

timeout 15 bash -c "until echo > /dev/tcp/localhost/$SERVICE_PORT; do sleep 0.5; done"
