#!/bin/bash

#Displays the main menu and handles all database-level operations

main_menu(){
	echo
	echo ----------------------------------------------------------
	echo Hello, `whoami`    Welcom to our database managment system
	echo
	echo Created by youssef salah and Mohamed Hamdy 
	echo ----------------------------------------------------------
	echo
	echo  _________________Main Menu________________
	
	# Infinite loop to keep showing the menu until user exits
	while true
	do
	# the ps3 is used to change the prompt of the select command
	PS3="Your Choice Is: "
    # read is for input 
	choice=read
	
		# database operations
		select choice in "create database" "List Databases" "Connect to databases " "Drop Database" "Exit from DBMS" 
		do
	
		case $REPLY in
		1)  # Create a new database
		clear 
        # read and store in var $REPLY and -p is for prompt
		read -p "Enter a name for the database: "; 
		
		# Check if database directory already exists
		if [[ -d databases/$REPLY ]];then
		echo 'Database already exists'	
		else  
		# Create new database directory
		`mkdir databases/${REPLY}`
			echo ${REPLY} database created succsessfully
			fi
			break
		;;
		
		2)  # List all existing databases
		clear
		echo
		echo The available databases are:
		# List all databases 
		ls -1 databases
		echo
		echo ---------------------------
		break
		;;
		
		3)  # Connect to an existing database
		clear
		read -p "Enter the name of the database you want to connect with: " connectedDB
		
		# Check if the database directory exists, variabe holds the name (cause $reply will be used in anther func)
		if [[ -d databases/$connectedDB ]];then
			clear
			echo You are now connected to $connectedDB database
			# Call the table() function to show table operations menu
			table
		else
			echo
			echo No database with name $connectedDB
			echo
			echo -----------------------------------
		fi 
		break
		;;
		
		4)  # Drop (delete) a database
		clear
		read -p "Enter the name of the database you want to drop: "
		
		# Check if database exists before deleting
		if [[ -d databases/$REPLY ]];then
			# Remove the entire database directory and its contents
			`rm -r databases/$REPLY`
			echo $REPLY dropped sucsessfully
		else
			echo their is no database with this name
		fi
		break
		;;
		
		5)  # Exit the application
			exit
			;;
			
		*)  # Handle invalid input
		echo $REPLY is  invalid choice
			break
			;;
		esac
	done
	done
}
