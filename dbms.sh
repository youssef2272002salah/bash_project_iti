#!/bin/bash

# Create the databases directory 
mkdir -p databases

# path of the directory 
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# table operations 
source "$SCRIPT_DIR/lib/table_operations.sh"

# database operations 
source "$SCRIPT_DIR/lib/database_operations.sh"

# call main menu
main_menu



