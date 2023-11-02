#!/bin/bash

rollback_change_log() {
  local change_log="$1"
  local rollback_dir="/home/ubuntu/backup"

  # Check if the change.log file exists
  if [ -e "$change_log" ]; then
    while IFS= read -r line; do
      # Split the line into components (source, destination, timestamp, etc.)
      IFS=',' read -r source destination timestamp <<< "$line"

      # Check if the source file exists in the backup directory
      if [ -e "$rollback_dir/$source" ]; then
        # Perform the rollback
        echo "Rolling back $source to $destination"
        cp "$rollback_dir/$source" "$destination"

        if [ $? -eq 0 ]; then
          echo "Rolled back $source to $destination"
        else
          echo "Error rolling back $source to $destination"
        fi
      else
        echo "Backup file $source not found, skipping rollback"
      fi
    done < "$change_log"
  else
    echo "Change log file not found"
  fi
}

# Check if the change.log file is provided as an argument
if [ $# -eq 1 ]; then
  rollback_change_log "$1"
else
  echo "Usage: $0 <change.log>"
fi
