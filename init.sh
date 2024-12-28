#!/bin/bash

# check if all expected volume folders and .env files are present

env_files=(
  "/hdd/volumes/.factorio.env"
  "/hdd/volumes/.foundry.env"
  "/hdd/volumes/.qbit.env"
  "/hdd/volumes/.plex.env"
  "/hdd/volumes/.tunnel.env"
  "/hdd/volumes/.immich.env"
)

volume_dirs=(
  "/hdd/volumes/factorio"
  "/hdd/volumes/foundry_1"
  "/hdd/volumes/jellyfin"
  "/hdd/movies"
  "/hdd/tv"
  "/hdd/volumes/plex"
  "/hdd/volumes/prowlarr"
  "/hdd/downloads"
  "/hdd/volumes/qbit"
  "/hdd/volumes/radarr"
  "/hdd/volumes/sonarr"
  "/hdd/volumes/syncthing"
  "/hdd/volumes/uptime"
  "/hdd/volumes/immich_data"
  "/hdd/volumes/immich_cache"
  "/hdd/volumes/immich_upload"
)

# Function to check existence
check_existence() {
  missing_items=()
  for item in "$@"; do
    if [ ! -e "$item" ]; then
      missing_items+=("$item")
    fi
  done

  if [ ${#missing_items[@]} -eq 0 ]; then
    echo "All items exist."
  else
    echo "The following items are missing:"
    for missing in "${missing_items[@]}"; do
      echo "  - $missing"
    done
    return 1
  fi
}

# Check environment files
echo "Checking environment files..."
check_existence "${env_files[@]}" || echo "Some environment files are missing!"

# Check volume directories
echo "Checking volume directories..."
check_existence "${volume_dirs[@]}" || echo "Some volume directories are missing!"
