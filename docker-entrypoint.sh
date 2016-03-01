#!/bin/bash

# Exit the script in case of errors
set -e

SECRET_KEY_BASE="${SECRET_KEY_BASE:-$(rake secret)}"
export SECRET_KEY_BASE

cp -n /opt/dradis/db/production.sqlite3 /dbdata/
chown -R dradis:dradis /dbdata/
chmod -R u+w /dbdata/

if [ -z "${*}" ]
then
  exec su -m -l dradis -c 'exec bundle exec rails server'
else
  exec su -m -l dradis -c 'exec bundle exec rails server "$0" "$@"' -- "${@}"
fi
