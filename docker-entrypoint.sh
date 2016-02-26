#!/bin/bash

# Exit the script in case of errors
set -e

cp -n /opt/dradis/db/production.sqlite3 /dbdata/
chown -R dradis:dradis /dbdata/
chmod -R u+w /dbdata/

if [ -z "${*}" ]
then
  exec su -m -l dradis -c 'exec bundle exec rails server'
else
  exec su -m -l dradis -c 'exec bundle exec rails server "$0" "$@"' -- "${@}"
fi
