#!/bin/sh

set -e

rm -f "${APP_PATH}/tmp/pids/server.pid"

# If running the rails server then create or migrate existing database
if [ "${*}" == "./bin/rails server" ]; then
  ./bin/rails db:prepare
fi

exec "$@"
