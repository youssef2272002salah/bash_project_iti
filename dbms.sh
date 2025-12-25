#!/bin/bash

# Create the databases directory if it doesn't exist
mkdir -p databases

# Get the absolute path of the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load the table operations library
source "$SCRIPT_DIR/lib/table_operations.sh"

# Load the database operations library
source "$SCRIPT_DIR/lib/database_operations.sh"

# Start by call the main menu func
main_menu



