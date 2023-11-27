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

  # Backup the existing file or directory at the destination
  if [ -e "$destination" ]; then
    backup_dir="/ibm/IBM-CAS/BACKUP_RELEASE"
    mkdir -p "$backup_dir"
    backup_file="$backup_dir/$(basename "$destination")_backup_$(date +'%Y%m%d%H%M%S')"
    mv "$destination" "$backup_file"
    echo "Backed up $destination to $backup_file"

    # Add the backup details to the change.log file
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Backed up $destination to $backup_file" >> change.log
  else
    echo "File or directory $destination not found, skipping backup"
  fi

  # Download the ZIP file from GitHub Packages using curl
  # Replace GITHUB_TOKEN with your GitHub token or credentials
  curl -H "Authorization: token TOKEN_GITHUB" -o "$filename.zip" -L "https://npm.pkg.github.com/Rakbank-DEH-Onboarding/$filename.zip"

  if [ $? -eq 0 ]; then
    echo "Downloaded $filename.zip from GitHub Packages"

    # Unzip the file
    unzip -q "$filename.zip" -d "$destination"

    if [ $? -eq 0 ]; then
      echo "Extracted and deployed $filename.zip to $destination"
    else
      echo "Error extracting and deploying $filename.zip to $destination"
    fi

    # Add the deployment details to the change.log file
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Deployed $filename.zip to $destination" >> change.log
  else
    echo "Error downloading $filename.zip from GitHub Packages"
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
