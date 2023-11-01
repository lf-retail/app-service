#!/bin/bash

process_line() {
  local filename
  local destination

  IFS=',' read -r filename destination <<< "$1"

  echo "Deploying $filename to $destination"

  if [ -z "$filename" ] || [ -z "$destination" ]; then
    echo "Error: Empty filename or destination in line: $1"
    return
  fi

  # Backup the file or directory before deploying
  backup_dir="/home/ubuntu/backup"
  backup_file="$backup_dir/$(basename "$destination")_backup_$(date +'%Y%m%d%H%M%S')"
  if [ -e "$destination" ]; then
   if [[ -d "$destination" ]]; then
     cp -r "$destination" "$backup_file"  # If it's a directory
   elif [[ -f "$destination" ]]; then
     cp "$destination" "$backup_file"  # If it's a file
   fi
   echo "Backed up $destination to $backup_file"
  else
   echo "File or directory $destination not found, skipping backup"
  fi

  # Add your deployment logic here
  # For example, you can use 'cp' to copy the file from the source to the destination:
  cp "$filename" "$destination"

  if [ $? -eq 0 ]; then
    echo "Copied $filename to $destination"
  else
    echo "Error copying $filename to $destination"
  fi
}

# Check if the release.txt file exists
if [ -e "release.zip" ]; then
  # Unzip the release.zip file
  unzip -o "release.zip" -d "unzipped_release"

  # Check if the unzipped release.txt file exists
  if [ -e "unzipped_release/release.txt" ]; then
    # Read each line from the unzipped release.txt file
    while IFS= read -r line; do
      # Skip empty lines and lines starting with #
      if [[ -n "$line" && "$line" != "#"* ]]; then
        process_line "$line"
      fi
    done < "unzipped_release/release.txt"
  else
    echo "unzipped_release/release.txt file not found"
  fi
else
  echo "release.zip file not found"
fi
