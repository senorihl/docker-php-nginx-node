#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

DEV_UID=${DEV_UID:=}

if [ "$DEV_UID" != "" ]; then
  usermod -u ${DEV_UID} www-data
  groupmod -g ${DEV_UID} www-data
fi

exec "$@"
