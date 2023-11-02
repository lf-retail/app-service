#!/bin/bash

# Define the path to the change.log file
change_log="change.log"

rollback() {
  local rollback_info
  local backup_file
  local destination
  local timestamp

  # Read the change.log file in reverse order (latest changes first)
  tac "$change_log" | while IFS= read -r rollback_info; do
    if [[ "$rollback_info" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}) - Backed up (.+) to (.+)$ ]]; then
      timestamp="${BASH_REMATCH[1]}"
      backup_file="${BASH_REMATCH[2]}"
      destination="${BASH_REMATCH[3]}"

      # Check if the backup file and destination exist
      if [ -e "$backup_file" ] && [ -e "$destination" ]; then
        echo "Rolling back $backup_file to $destination"

        # Perform the rollback by copying the backup file back to the destination
        cp -r "$backup_file" "$destination"

        if [ $? -eq 0 ]; then
          echo "Rolled back $backup_file to $destination"
          # Remove the line from the change.log file
          sed -i "\|$timestamp - Backed up $destination to $backup_file|d" "$change_log"
        else
          echo "Error rolling back $backup_file to $destination"
        fi
      fi
    fi
  done
}

# Check if the change.log file exists
if [ -e "$change_log" ]; then
  rollback
else
  echo "change.log file not found, unable to perform rollback"
fi
