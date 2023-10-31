process_line() {
  local filename
  local source
  local destination

  IFS=',' read -r filename source destination <<< "$1"

  echo "Deploying $filename from $source to $destination"

  if [ -z "$filename" ] || [ -z "$source" ] || [ -z "$destination" ]; then
    echo "Error: Empty filename, source, or destination in line: $1"
    return
  fi

  if [ -e "$destination" ]; then
    backup_dir="/home/ubuntu/backup"
    mkdir -p "$backup_dir"
    backup_file="$backup_dir/$(basename "$destination")_backup_$(date +'%Y%m%d%H%M%S')"
    cp -r "$destination" "$backup_file"
    echo "Backed up $destination to $backup_file"

    # Create a symbolic link to the latest backup
    latest_backup_link="/home/ubuntu/latest_backup"
    rm -f "$latest_backup_link"  # Remove the previous symlink if it exists
    ln -s "$backup_file" "$latest_backup_link"
  else
    echo "File $destination not found, skipping backup"
  fi

  cp "$source/$filename" "$destination"

  if [ $? -eq 0 ]; then
    echo "Copied $filename from $source to $destination"
  else
    echo "Error copying $filename from $source to $destination"
  fi
}

if [ -e "release.txt" ]; then
  while IFS= read -r line; do
    if [[ -n "$line" && "$line" != "#"* ]]; then
      process_line "$line"
    fi
  done < "release.txt"
else
  echo "release.txt file not found"
fi
