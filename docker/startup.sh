#!/bin/bash

# Ensure SQLite database directory exists and has correct permissions
mkdir -p /opt/focalboard/data
chmod -R 777 /opt/focalboard/data

# Remove any stale SQLite lock files to prevent "database is locked" errors
echo "Checking for and removing stale SQLite lock files..."
if [ -f /opt/focalboard/data/focalboard.db-wal ]; then
  echo "Removing stale WAL file..."
  rm -f /opt/focalboard/data/focalboard.db-wal
fi

if [ -f /opt/focalboard/data/focalboard.db-shm ]; then
  echo "Removing stale SHM file..."
  rm -f /opt/focalboard/data/focalboard.db-shm
fi

if [ -f /opt/focalboard/data/focalboard.db-journal ]; then
  echo "Removing stale journal file..."
  rm -f /opt/focalboard/data/focalboard.db-journal
fi

# Make sure the actual database file is writable
if [ -f /opt/focalboard/data/focalboard.db ]; then
  echo "Making database file writable..."
  chmod 666 /opt/focalboard/data/focalboard.db
  
  # Try to enable WAL mode, but don't fail if it doesn't work
  echo "Enabling WAL mode on existing database..."
  sqlite3 /opt/focalboard/data/focalboard.db "PRAGMA journal_mode=WAL;" || echo "Failed to set WAL mode, continuing anyway"
  
  # Try to reset any locks using SQLite
  echo "Attempting to reset database locks..."
  sqlite3 /opt/focalboard/data/focalboard.db "PRAGMA busy_timeout=5000; PRAGMA locking_mode=NORMAL; PRAGMA journal_mode=DELETE; VACUUM;" || echo "Failed to reset locks, continuing anyway"
  
  # Re-enable WAL mode after lock reset
  sqlite3 /opt/focalboard/data/focalboard.db "PRAGMA journal_mode=WAL;" || echo "Failed to set WAL mode after vacuum, continuing anyway"
fi

echo "Starting Focalboard server..."
exec /opt/focalboard/bin/focalboard-server
