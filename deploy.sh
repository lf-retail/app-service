process_line() {
  local filename
  local destination
  
  # Split the line into filename and destination using a comma as the delimiter 
  IFS=',' read -r filename destination <<< "$1"

  # Perform actions based on the values
  echo "Deploying $filename to $destination"

  # Check if either the filename or destination is empty
  if [ -z "$filename" ] || [ -z "$destination" ]; then
    echo "Error: Empty filename or destination in line: $1"
    return
  fi

  # Backup the existing file at the destination
  if [ -e "$destination" ]; then
    backup_dir="/home/ubuntu/backup"
    mkdir -p "$backup_dir"
    backup_file="$backup_dir/$(basename "$destination")_backup_$(date +'%Y%m%d%H%M%S')"
    cp -r "$destination" "$backup_file"
    echo "Backed up $destination to $backup_file"

    # Add the backup details to the change.log file
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Backed up $destination to $backup_file" >> change.log
  else
    echo "File $destination not found, skipping backup"
  fi

  # Download the file from GitHub Packages using curl
  # Replace GITHUB_TOKEN with your GitHub token or credentials
  curl -H "Authorization: token GITHUB_TOKEN" -o "$filename" -L "https://npm.pkg.github.com/your-organization/$filename"

  if [ $? -eq 0 ]; then
    echo "Downloaded $filename from GitHub Packages"

    # Add your deployment logic here
    # For example, you can use 'cp' to copy the file from the source to the destination:
    cp "$filename" "$destination"

    if [ $? -eq 0 ]; then
      echo "Copied $filename to $destination"
    else
      echo "Error copying $filename to $destination"
    fi
  else
    echo "Error downloading $filename from GitHub Packages"
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
