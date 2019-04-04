#!/bin/sh

# Don't allow this command to fail
set -e
echo "Waiting for db"
/app/wait-for db:5432 -t 45 -- echo "Db is up"

# Allow this command to fail
set +e
echo "Setting up db. OK to ignore errors about test db."
# https://github.com/rails/rails/issues/27299
rails db:create

# Don't allow any following commands to fail
set -e
echo "Migrating db"
rails db:migrate

echo "Running server"
exec puma -C config/puma.rb config.ru
