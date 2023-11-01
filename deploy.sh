process_line() {
  local filename
  local destination

  IFS=',' read -r filename destination <<< "$1"

  echo "Deploying $filename to $destination"

  if [ -z "$filename" ] || [ -z "$destination" ]; then
    echo "Error: Empty filename or destination in line: $1"
    return
  fi

  # Backup the file before deploying
  if [ -e "$destination" ]; then
    backup_dir="/home/ubuntu/backup"
    mkdir -p "$backup_dir"
    backup_file="$backup_dir/$(basename "$destination")_backup_$(date +'%Y%m%d%H%M%S')"
    cp -r "$destination" "$backup_file"
    echo "Backed up $destination to $backup_file"
  else
    echo "File $destination not found, skipping backup"
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
if [ -e "release.txt" ]; then
  # Read each line from the release.txt file
  while IFS= read -r line; do
    # Skip empty lines and lines starting with #
    if [[ -n "$line" && "$line" != "#"* ]]; then
      process_line "$line"
    fi
  done < "release.txt"
else
  echo "release.txt file not found"
fi
