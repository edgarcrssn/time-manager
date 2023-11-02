#!/bin/bash

source .env

while ! pg_isready -q -h db -p "$PGPORT" -U postgres
do
  echo "$(date) - waiting for database to start"
  sleep 1
done

mix setup
exec mix phx.server
