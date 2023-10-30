process_line() {
  local filename
  local source  # Add a new variable for the source location
  local destination

  # Split the line into filename, source, and destination using comma as the delimiter
  IFS=',' read -r filename source destination <<< "$1"

  # Perform actions based on the values
  echo "Deploying $filename from $source to $destination"
  
  # Check if either the filename, source, or destination is empty
  if [ -z "$filename" ] || [ -z "$source" ] || [ -z "$destination" ]; then
    echo "Error: Empty filename, source, or destination in line: $1"
    return
  fi

  # Backup the file before deploying
  if [ -e "$destination" ]; then
    backup_dir="backup"
    mkdir -p "$backup_dir"
    backup_file="$backup_dir/$(basename "$destination")_backup_$(date +'%Y%m%d%H%M%S')"
    cp "$destination" "$backup_file"
    echo "Backed up $destination to $backup_file"
  else
    echo "File $destination not found, skipping backup"
  }
  
  # Add your deployment logic here
  # For example, you can use 'cp' to copy the file to the destination:
  cp "$source/$filename" "$destination"

  if [ $? -eq 0 ]; then
    echo "Copied $filename from $source to $destination"
  else
    echo "Error copying $filename from $source to $destination"
  }
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
