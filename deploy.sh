process_line() {
  local filename
  local destination

  # Split the line into filename and destination using comma as the delimiter
  IFS=',' read -r filename destination <<< "$1"

  # Perform actions based on the values
  echo "Deploying $filename to $destination"
  
  # Check if either the filename or destination is empty
  if [ -z "$filename" ] || [ -z "$destination" ]; then
    echo "Error: Empty filename or destination in line: $1"
    return
  fi
  
  # Add your deployment logic here
  # For example, you can use 'cp' to copy the file to the destination:
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
