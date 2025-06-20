#!/bin/bash

# Ensure SQLite database directory exists and has correct permissions
mkdir -p /opt/focalboard/data
chmod 777 /opt/focalboard/data

# Enable WAL mode on SQLite database if it exists
if [ -f /opt/focalboard/data/focalboard.db ]; then
  echo "Enabling WAL mode on existing database..."
  sqlite3 /opt/focalboard/data/focalboard.db "PRAGMA journal_mode=WAL;"
fi

# Start Focalboard server
exec /opt/focalboard/bin/focalboard-server
