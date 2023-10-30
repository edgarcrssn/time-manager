#!/bin/bash

source .env

if [ ! -f .env ]; then
  echo "The .env file is not found. Stopping the api container..."
  docker-compose stop api
  echo "api container stopped."
fi

while ! pg_isready -q -h db -p "$PGPORT" -U postgres
do
  echo "$(date) - waiting for database to start"
  sleep 1
done

mix setup
exec mix phx.server