#!/bin/sh

set -eu

mkdir -p /host/opt/central/bin
cp /usr/bin/cadvisor /host/opt/central/bin/cadvisor

COMMAND="nsenter --target 1 --mount --uts --net --pid -- /opt/central/bin/cadvisor --logtostderr $@"
# Launch cadvisor
exec $COMMAND
