#!/bin/sh
# Copyright 2022 Hardfin, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Usage:
#  ./tailscale-entrypoint.sh
# Runs Tailscale daemon and Tailscale up command. This is assumed to be running
# in a container.

set -e

## Validate and read inputs

if [ "${#}" -ne 0 ]
then
  echo "Usage: ./tailscale-entrypoint.sh" >&2
  exit 1
fi

if [ -z "${TS_RELAY_HOSTNAME}" ]; then
  echo "TS_RELAY_HOSTNAME environment variable should be set by the caller." >&2
  exit 1
fi

if [ -z "${TS_RELAY_AUTH_KEY}" ]; then
  echo "TS_RELAY_AUTH_KEY environment variable should be set by the caller." >&2
  exit 1
fi

if [ -z "${TS_RELAY_ADVERTISE_ROUTES}" ]; then
  echo "TS_RELAY_ADVERTISE_ROUTES environment variable should be set by the caller." >&2
  exit 1
fi

# Setup iptables
iptables -t nat -A POSTROUTING -o tailscale0 -j MASQUERADE

if [ ! -d /dev/net ]; then mkdir /dev/net; fi
if [ ! -e /dev/net/tun ]; then  mknod /dev/net/tun c 10 200; fi

## Start `tailscaled` and background it

echo "Starting tailscaled"
tailscaled --state=/var/lib/tailscale/tailscaled.state
TS_RELAYD_PID="${!}"

## Run `tailscale up`

tailscale up \
  --hostname "${TS_RELAY_HOSTNAME}" \
  --authkey "${TS_RELAY_AUTH_KEY}" \
  --advertise-routes "${TS_RELAY_ADVERTISE_ROUTES}" \
  ${TS_RELAY_ADDITIONAL_FLAGS}

## Wait on `tailscaled`

wait "${TS_RELAYD_PID}"