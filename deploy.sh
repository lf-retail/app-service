#!/bin/bash

# Define a function to process each line
process_line() {
  local filename
  local destination

  # Split the line into filename and destination using comma as the delimiter
  IFS=',' read -r filename destination <<< "$1"

  # Perform actions based on the values
  echo "Deploying $filename to $destination"

  # Add your deployment logic here
  # For example, you can use 'cp' to copy the file to the destination:
  # cp "$filename" "$destination"
}


