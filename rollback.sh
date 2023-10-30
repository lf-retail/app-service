#!/bin/bash

rollback_line() {
  local backup_file
  local destination

  # Split the line into backup_file and destination using comma as the delimiter
  IFS=',' read -r backup_file destination <<< "$1"

  # Perform actions based on the values
  echo "Rolling back $backup_file to $destination"

  # Check if either the backup_file or destination is empty
  if [ -z "$backup_file" ] || [ -z "$destination" ]; then
    echo "Error: Empty backup_file or destination in line: $1"
  fi

  # Perform the rollback logic here
  # For example, you can use 'cp' to copy the backup_file to the destination:
  cp "$backup_file" "$destination"

  if [ $? -eq 0 ]; then
    echo "Rolled back $backup_file to $destination"
  else
    echo "Error rolling back $backup_file to $destination"
  fi
}

# Check if the rollback.txt file exists
if [ -e "$1" ]; then
  # Read each line from the rollback.txt file
  while IFS= read -r line; do
    # Skip empty lines and lines starting with #
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
