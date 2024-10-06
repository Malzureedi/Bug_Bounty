#!/bin/bash

# Check if the input file is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <cidr_list_file>"
  exit 1
fi

# Read CIDR list from the provided file
CIDR_FILE=$1

# Check if the file exists
if [ ! -f "$CIDR_FILE" ]; then
  echo "File not found: $CIDR_FILE"
  exit 1
fi

# Create or clear the results file
RESULTS_FILE="nmap_style_results.txt"
echo "Shodan Search Results (Nmap Style)" > "$RESULTS_FILE"
echo "==================================" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# Function to clean and format Shodan output to look more like Nmap
format_shodan_output() {
  awk '{
    if ($1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) { # Check for IP address
      ip = $1;
    }
    if ($2 ~ /^[0-9]+$/) { # Check for port number
      port = $2;
    }
    if ($3 != "") { # Check for service information
      service = $3;
      print ip " " port "/tcp open " service;
    }
  }'
}

# Loop through each CIDR in the file and run a Shodan search
while IFS= read -r cidr; do
  echo "Searching Shodan for CIDR: $cidr"
  echo "Results for CIDR: $cidr" >> "$RESULTS_FILE"
  echo "------------------------" >> "$RESULTS_FILE"
  
  # Run the Shodan search and clean the output to be Nmap-like
  shodan search --limit 100 "net:$cidr" | format_shodan_output >> "$RESULTS_FILE"
  
  echo "" >> "$RESULTS_FILE" # Add a blank line for separation
done < "$CIDR_FILE"

echo "Search complete. Results saved to $RESULTS_FILE."
