#!/bin/bash

rollback_line() {
  local backup_file
  local destination

  IFS=',' read -r backup_file destination <<< "$1"

  echo "Rolling back $backup_file to $destination"

  if [ -z "$backup_file" ] || [ -z "$destination" ]; then
    echo "Error: Empty backup_file or destination in line: $1"
    return
  fi

  if [ -e "$backup_file" ]; then
    # Check if the destination directory exists, and if not, create it
    if [ ! -d "$destination" ]; then
      mkdir -p "$destination"
    fi

    # Rollback the backup file to the destination
    cp -r "$backup_file" "$destination/"

    if [ $? -eq 0 ]; then
      echo "Rolled back $backup_file to $destination"
    else
      echo "Error rolling back $backup_file to $destination"
    fi
  else
    echo "Backup file $backup_file not found, skipping rollback"
  fi
}

# Check if the rollback.txt file exists
if [ -e "$1" ]; then
  while IFS= read -r line; do
    if [[ -n "$line" && "$line" != "#"* ]]; then
      rollback_line "$line"
    fi
  done < "$1"
else
  echo "Rollback file not found"
fi

# Exit with a non-zero status code if there were errors during rollback
if [ $? -ne 0 ]; then
  exit 1
fi
