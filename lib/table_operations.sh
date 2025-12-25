#!/bin/bash

# Description: Displays table data with options to select all records or specific records

select_from(){
	clear
	echo
	# Get the table name from user
	read -p "Enter table name to select from: " tblname
	
	# Check if the table file exists in the current database
	if [[ -f databases/$connectedDB/$tblname ]]; then
		# Show menu: select all or select specific records
		select choice in "select all" "select specific records"
		do
		case $REPLY in
			1)  # Select all records
			# Print column headers from metadata file (line 5)
			# FS="," sets field separator to comma, printf formats output with 5-char width
            awk -F, 'NR==5 {for (i=1;i<=NF;i++) printf "%s ", $i; print ""}' databases/$connectedDB/.$tblname"_metadata"
			
			# Print all data rows from the table
            awk -F, '{for (i=1;i<=NF;i++) printf "%s ", $i; print ""}' databases/$connectedDB/$tblname
			echo
			echo
			# Return to table menu
			table

			;;
				
			2)  # Select specific record by primary key
			# Extract the primary key column name from metadata
			pk_name=`awk -F, '{if(NR==5){print$1}}' databases/$connectedDB/.$tblname"_metadata";`
			read -p "Enter $pk_name value: " val;
			
			# Print column headers
            awk -F, 'NR==5 {for (i=1;i<=NF;i++) printf "%s ", $i; print ""}' databases/$connectedDB/.$tblname"_metadata"
			
			# Search for record with matching primary key (starts with val)
			# Store result in temporary file
			cat databases/$connectedDB/$tblname|grep ^$val>databases/$connectedDB/temp2
			
			# Display the matching record
			awk 'BEGIN{FS=","}{for (i=1;i<=NF;i++) printf "%-5s",$i; print ""}' databases/$connectedDB/temp2
			
			# Clean up temporary file
			rm databases/$connectedDB/temp2 2>/dev/null

			echo
			echo
			table
			;;
			*)  # Invalid choice
			echo wrong choice
			table
		esac
		done
		echo
	else
		echo
		echo There is no table with this name
		table
	fi

}

# Description: Deletes records from a table all records or specific record by primary key)
delete_from(){
	clear
	# Get the table name from user
	read -p "Enter table name to delete from: " tblname
	
	# Check if table exists
	if [[ -f databases/$connectedDB/$tblname ]]; then
		select choice in "delete all records" "delete a specific record"
		do
		case $REPLY in
			1)  # Delete all records 
			# Use redirection to empty the file (keeps the file but removes content)
            cat /dev/null > databases/$connectedDB/$tblname
			echo All records has been deleted
			echo
			table

			;;
				
			2)  # Delete specific record by primary key
			# Get primary key column name from metadata
			pk_name=`awk -F, '{if(NR==5){print$1}}' databases/$connectedDB/.$tblname"_metadata";`
			read -p "Enter $pk_name value: " val
			
            
            # grep -v → selects lines that do NOT match the pattern
            # ^$val → matches lines that start with $val (primary key)
            # Redirect output to a temporary file temp.csv
            
            
            grep -v ^$val databases/$connectedDB/$tblname>databases/$connectedDB/temp.csv
			
			# Replace original table with the temp file (record deleted)
			mv databases/$connectedDB/temp.csv databases/$connectedDB/$tblname
			
			# Clean up any remaining temp file
			rm databases/$connectedDB/temp.csv 2>/dev/null
			echo record with id : $val had been deleted
			echo
            # Return to table menu
			table

			
		esac
		done
		echo
		echo -----------------
		table
	else
		echo There is no table with this name
		echo
		echo -----------------
		table
	fi
}

#--------------------------------------------
# Function: table
# Description: Main table menu that handles all table


# Operations:
#   1. Create table
#   2. List tables
#   3. Drop table
#   4. Show metadata
#   5. Insert to table
#   6. Select from table
#   7. Delete from table
#   8. Back to main menu
#--------------------------------------------
table(){
    echo
	echo _______________$connectedDB Database_______________
	echo
choice=read

# Display table operations menu
select choice in "create table" "list tables" "drop table" "show meta data of a table" "insert to table" "select from table" "delete from table" "back to main menu" 
	do
	# Handle user's choice
	case $REPLY in
	
	1)  # Create a new table
	clear
	read -p "Enter a name for the table: " tblname
	
	# Check if table already exists
	if [[ -f databases/$connectedDB/$tblname ]];then
		echo table already exists
		echo
		echo --------------------
		table
	else
		# Get number of columns for the table
		read -p "Enter number of columns :" cols;
		
		# Validate that at least one column is specified
        if [[ $cols -le 0 ]]; then
			echo Cannot create a table with invalid num of columns
			table
		fi
		
		# Create the table file and its metadata file
		# Metadata file starts with a dot (hidden file)
		`touch databases/$connectedDB/$tblname`
		`touch databases/$connectedDB/.$tblname"_metadata"`
		`chmod -R 777 databases/$connectedDB/$tblname`
		
		# Write table information to metadata file
		echo "Table Name:"$tblname >> databases/$connectedDB/.$tblname"_metadata"
		echo "Number of columns:"$cols >> databases/$connectedDB/.$tblname"_metadata"
		
		# Array to store column names for duplicate checking
		declare -a column_names=()

		# Loop through each column to get column names
		for (( i = 1; i <= cols; i++ )); do
			if [[ i -eq 1 ]];then
				# First column is always the primary key
				read -p "Enter column $i name as a primary key: " name;
				
				# Add to column names array
				column_names+=("$name")
				
				echo "The primary key for this table is: "$name >> databases/$connectedDB/.$tblname"_metadata";
				echo "Names of columns: " >> databases/$connectedDB/.$tblname"_metadata"
				# Write column name with comma , -n not to get new line   ---> id,name,age
				echo -n $name",  " >> databases/$connectedDB/.$tblname"_metadata";

			elif [[ i -eq cols ]];then
				read -p "Enter column $i name: " name;
				
				# Check for duplicate column name
				for col in "${column_names[@]}"; do
					if [[ "$col" == "$name" ]]; then
						echo "Error: Column name '$name' already exists! Cannot have duplicate column names."
						# Clean up created files
						rm databases/$connectedDB/$tblname
						rm databases/$connectedDB/.$tblname"_metadata"
						table
					fi
				done
				
                 # without ,
				echo -n $name >> databases/$connectedDB/.$tblname"_metadata";
			else
				read -p "Enter column $i name: " name;
				
				# Check for duplicate column name
				for col in "${column_names[@]}"; do
					if [[ "$col" == "$name" ]]; then
						echo "Error: Column name '$name' already exists! Cannot have duplicate column names."
						# Clean up created files
						rm databases/$connectedDB/$tblname
						rm databases/$connectedDB/.$tblname"_metadata"
						table
					fi
				done
				
				# Add to column names array
				column_names+=("$name")
				
				echo -n $name",  " >> databases/$connectedDB/.$tblname"_metadata";	
			fi 
		done 
		clear
		echo Table created sucsessfully
		table
	fi

	;;
	





	2)  # List all tables in the current database
	# -z checks if the directory is empty

	if [ -z "$(ls -A -- databases/$connectedDB)" ]; then
		clear
		echo
		echo This database is empty
		echo
		echo ----------------------
		table
	else
		clear
		echo
		echo The tables of this database are: 
			ls -1 databases/$connectedDB
		echo
		echo ----------------------
		table
	fi
		;;
		





	3)  # Drop a table
	echo 
	clear
		read -p "Enter name of the table you want to drop:"
		
		# Check if table exists
		if [[ -f databases/$connectedDB/$REPLY ]];then
			# Remove both the table file and its metadata file
			rm databases/$connectedDB/$REPLY
			rm databases/$connectedDB/.$REPLY"_metadata"
			echo table removed successfully
			echo
			echo -------------------------
			table
		else
			echo no table with this name
			echo
			echo --------------------------
			table
		fi
		;;
		






	4)  # Show metadata
	clear
	echo
	read -p "Enter the table name: " tblname
	
	# Check if table exists
	if [[ -f databases/$connectedDB/$tblname ]];then
			cat databases/$connectedDB/.$tblname"_metadata"
			echo
		else
			echo There is no table with this name
		fi
	echo ------------------
	table
	;;
	









	5)  # Insert into 
	clear
	read -p "Enter the table name: " tblname
	
	# Check if table exists
	if [[ -f databases/$connectedDB/$tblname ]]; then
    # first take the num of col from metadata file ----> this is in line 5 
    # firrst declare cols as integer
    # second use awk to get the number of fields in line 5  --> NR is line number 
    # make field separator as , then print NF (number of fields)

	typeset -i cols=`awk -F, '{if(NR==5){print NF}}' databases/$connectedDB/.$tblname"_metadata";`
	
	# Loop through each column to get values from user
	for (( i = 1; i <= $cols; i++ )); do
		# Extract column name for current iteration
    #-v"i=$i" → passes Bash variable i to awk
# print $i → gets the name of the i-th column

	 	colname=`awk -F, -v"i=$i" '{if(NR==5){print $i}}' databases/$connectedDB/.$tblname"_metadata";`
	 	# Remove leading/trailing whitespace from column name
	 	colname=$(echo "$colname" | xargs)
	 	
		read -p "Enter $colname: " value;
		
		# Check for duplicate primary key (first column is always primary key)
        if [[ $i -eq 1 ]]; then
				# Get all existing primary keys from the table (first field of each line)
				if [[ -s databases/$connectedDB/$tblname ]]; then
					pks=`cut -f1 -d, databases/$connectedDB/$tblname`
					
					# Check each existing primary key
					for j in $pks 
					do					
						if [[ "$j" == "$value" ]]; then
							echo "Error: Primary key '$value' already exists! Cannot insert duplicate primary key."
							table
						fi
					done
				fi
		fi 2>/dev/null
		
			# Write value to table file
			# Add comma separator between values, except for the last column
			if [[ $i != $cols ]]; then
				echo -n $value"," >> databases/$connectedDB/$tblname;
			else	
				# Last column - add newline instead of comma
				echo $value >> databases/$connectedDB/$tblname;
			fi
	done 
	echo "Data has been inserted successfully"
	echo
	echo
	table
 	
	else
		echo "$tblname doesn't exist";
		echo
		table
	fi
	;;
	
	6)  # Select from tabl
	select_from
	;;
	
	7)  # Delete from table
	delete_from
	;;
	
	8)  # Back to main menu
    # holds the name of the currently running script ---> dbms.sh
		clear
		exec $0 
	;;
		
	*)  # Invalid choice
	clear
	echo "Wrong choice"
		break 2
	esac
done
}
